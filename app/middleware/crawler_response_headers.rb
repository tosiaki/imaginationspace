class CrawlerResponseHeaders
  ROBOTS_BODY = "User-agent: *\nDisallow: /\n".freeze
  ROBOTS_DIRECTIVE = "noindex, nofollow, noarchive, nosnippet".freeze
  PUBLIC_RETIREMENT_CACHE_CONTROL = "public, max-age=86400".freeze
  PRIVATE_PATHS = ["/account", "/login", "/logout", "/s3"].freeze

  def initialize(app)
    @app = app
  end

  def call(environment)
    status, headers, body = @app.call(environment)
    headers["X-Robots-Tag"] ||= ROBOTS_DIRECTIVE
    if [301, 308, 410].include?(status)
      replace_header(headers, "Cache-Control", PUBLIC_RETIREMENT_CACHE_CONTROL)
    elsif PRIVATE_PATHS.any? { |path| environment["PATH_INFO"] == path || environment["PATH_INFO"].start_with?("#{path}/") }
      replace_header(headers, "Cache-Control", "no-store")
    end
    if status == 200 && environment["PATH_INFO"] == "/robots.txt"
      replace_header(headers, "Cache-Control", PUBLIC_RETIREMENT_CACHE_CONTROL)
    end
    [status, headers, body]
  end

  private

  def replace_header(headers, name, value)
    headers.keys.grep(/\A#{Regexp.escape(name)}\z/i).each { |key| headers.delete(key) }
    headers[name] = value
  end
end
