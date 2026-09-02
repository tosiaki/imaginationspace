class CrawlerResponseHeaders
  ROBOTS_BODY = "User-agent: *\nDisallow: /\n".freeze
  ROBOTS_DIRECTIVE = "noindex, nofollow, noarchive, nosnippet".freeze
  REDIRECT_CACHE_CONTROL = "public, max-age=86400".freeze
  PRIVATE_PATHS = ["/account", "/login", "/logout"].freeze

  def initialize(app)
    @app = app
  end

  def call(environment)
    status, headers, body = @app.call(environment)
    headers["X-Robots-Tag"] ||= ROBOTS_DIRECTIVE
    if [301, 308].include?(status)
      headers["Cache-Control"] = REDIRECT_CACHE_CONTROL
    elsif PRIVATE_PATHS.any? { |path| environment["PATH_INFO"] == path || environment["PATH_INFO"].start_with?("#{path}/") }
      headers["Cache-Control"] = "no-store"
    end
    if status == 200 && environment["PATH_INFO"] == "/robots.txt"
      headers["Cache-Control"] = REDIRECT_CACHE_CONTROL
    end
    [status, headers, body]
  end
end
