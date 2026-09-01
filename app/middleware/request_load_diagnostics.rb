require "digest"
require "json"

class RequestLoadDiagnostics
  DEFAULT_THRESHOLDS = {
    query_count: 25,
    sql_ms: 100.0,
    max_sql_ms: 50.0,
    request_ms: 500.0
  }.freeze

  def initialize(app, options = {})
    @app = app
    @logger = options.fetch(:logger) { Rails.logger }
    @thresholds = DEFAULT_THRESHOLDS.merge(options.fetch(:thresholds, {}))
  end

  def call(environment)
    started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    request_thread = Thread.current
    queries = []
    cached_query_count = 0
    response = nil

    subscriber = lambda do |_name, start, finish, _id, payload|
      next unless Thread.current.equal?(request_thread)
      next if %w[SCHEMA TRANSACTION].include?(payload[:name])

      if payload[:cached] || payload[:name] == "CACHE"
        cached_query_count += 1
      else
        queries << {
          duration_ms: (finish - start) * 1_000,
          fingerprint: fingerprint(payload[:sql])
        }
      end
    end

    response = ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
      @app.call(environment)
    end
  ensure
    request_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1_000
    begin
      emit_diagnostic(environment, response, queries, cached_query_count, request_ms)
    rescue StandardError => diagnostic_error
      Rails.logger.error(
        "request_load_diagnostic_error=#{diagnostic_error.class.name}"
      ) rescue nil
    end
  end

  private

    def fingerprint(sql)
      normalized = sql.to_s
        .gsub(%r{/\*.*?\*/}m, " ")
        .gsub(/--[^\r\n]*/, " ")
        .gsub(/'(?:''|[^'])*'/, "?")
        .gsub(/\b\d+(?:\.\d+)?\b/, "?")
        .gsub(/\s+/, " ")
        .strip

      {
        id: Digest::SHA256.hexdigest(normalized).first(12),
        sql: normalized.first(240)
      }
    end

    def emit_diagnostic(environment, response, queries, cached_query_count, request_ms)
      sql_ms = queries.sum { |query| query[:duration_ms] }
      max_sql_ms = queries.map { |query| query[:duration_ms] }.max || 0.0
      reasons = []
      reasons << "query_count" if queries.length >= @thresholds[:query_count]
      reasons << "sql_ms" if sql_ms >= @thresholds[:sql_ms]
      reasons << "max_sql_ms" if max_sql_ms >= @thresholds[:max_sql_ms]
      reasons << "request_ms" if request_ms >= @thresholds[:request_ms]
      return if reasons.empty?

      parameters = environment.fetch("action_dispatch.request.path_parameters", {})
      fingerprints = queries.group_by { |query| query[:fingerprint] }.map do |fingerprint, matches|
        {
          id: fingerprint[:id],
          sql: fingerprint[:sql],
          count: matches.length,
          total_ms: rounded(matches.sum { |query| query[:duration_ms] }),
          max_ms: rounded(matches.map { |query| query[:duration_ms] }.max)
        }
      end.sort_by { |entry| [-entry[:count], -entry[:total_ms]] }.first(5)

      headers = response ? response[1] : {}
      @logger.warn({
        event: "request_load_diagnostic",
        version: 1,
        reasons: reasons,
        method: environment["REQUEST_METHOD"],
        controller: parameters[:controller] || parameters["controller"],
        action: parameters[:action] || parameters["action"],
        route: normalized_route(environment),
        status: response ? response[0] : 500,
        request_ms: rounded(request_ms),
        query_count: queries.length,
        cached_query_count: cached_query_count,
        sql_ms: rounded(sql_ms),
        max_sql_ms: rounded(max_sql_ms),
        response_bytes: headers["Content-Length"]&.to_i,
        cache_control: headers["Cache-Control"],
        sql_fingerprints: fingerprints
      }.to_json)
    end

    def rounded(value)
      value.round(2)
    end

    def normalized_route(environment)
      environment["action_dispatch.route_uri_pattern"] ||
        ActionDispatch::Request.new(environment).route_uri_pattern
    rescue ActionController::RoutingError
      nil
    end
end
