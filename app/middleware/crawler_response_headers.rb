class CrawlerResponseHeaders
  ROBOTS_BODY = "User-agent: *\nDisallow: /\n".freeze
  ROBOTS_DIRECTIVE = "noindex, nofollow, noarchive, nosnippet".freeze
  REDIRECT_CACHE_CONTROL = "public, max-age=86400".freeze

  def initialize(app)
    @app = app
  end

  def call(environment)
    status, headers, body = @app.call(environment)
    headers["X-Robots-Tag"] ||= ROBOTS_DIRECTIVE
    headers["Cache-Control"] = REDIRECT_CACHE_CONTROL if status.between?(300, 399)
    [status, headers, body]
  end
end
