require "rails_helper"

RSpec.describe RequestLoadDiagnostics do
  class DiagnosticLogCollector
    attr_reader :entries

    def initialize
      @entries = []
    end

    def warn(entry)
      @entries << JSON.parse(entry)
    end
  end

  let(:environment) do
    {
      "REQUEST_METHOD" => "GET",
      "action_dispatch.request.path_parameters" => {
        controller: "articles",
        action: "index"
      },
      "action_dispatch.route_uri_pattern" => "/articles(.:format)"
    }
  end

  it "does not log requests below every threshold" do
    logger = DiagnosticLogCollector.new
    app = lambda do |_environment|
      ActiveSupport::Notifications.instrument(
        "sql.active_record",
        name: "Status Load",
        sql: "SELECT * FROM statuses"
      )
      [200, { "Content-Length" => "2" }, ["OK"]]
    end

    described_class.new(app, logger: logger).call(environment)

    expect(logger.entries).to be_empty
  end

  it "logs bounded fingerprints when a request crosses a threshold" do
    logger = DiagnosticLogCollector.new
    app = lambda do |_environment|
      2.times do
        ActiveSupport::Notifications.instrument(
          "sql.active_record",
          name: "User Load",
          sql: "SELECT * FROM users WHERE email = 'secret@example.com' AND id = 42"
        )
      end
      [200, { "Content-Length" => "2", "Cache-Control" => "public" }, ["OK"]]
    end
    middleware = described_class.new(
      app,
      logger: logger,
      thresholds: { query_count: 2, sql_ms: 10_000, max_sql_ms: 10_000, request_ms: 10_000 }
    )

    middleware.call(environment)

    expect(logger.entries.length).to eq(1)
    entry = logger.entries.first
    expect(entry.fetch("event")).to eq("request_load_diagnostic")
    expect(entry.fetch("reasons")).to eq(["query_count"])
    expect(entry.fetch("query_count")).to eq(2)
    expect(entry.fetch("controller")).to eq("articles")
    expect(entry.fetch("route")).to eq("/articles(.:format)")
    expect(entry.fetch("sql_fingerprints").first.fetch("count")).to eq(2)
    expect(entry.to_json).not_to include("secret@example.com")
    expect(entry.fetch("sql_fingerprints").first.fetch("sql")).to include("email = ?", "id = ?")
  end
end
