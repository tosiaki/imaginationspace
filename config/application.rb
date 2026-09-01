require_relative "boot"

require "logger"
require "rails/all"
require_relative "../app/middleware/crawler_response_headers"
require_relative "../app/middleware/request_load_diagnostics"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fancomics
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1
    config.active_storage.variant_processor = :mini_magick

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #
    config.assets.paths << Rails.root.join('node_modules')
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    config.active_job.queue_adapter = :async
    config.middleware.insert_before 0, CrawlerResponseHeaders
    if Rails.env.production?
      config.middleware.insert_after CrawlerResponseHeaders, RequestLoadDiagnostics,
        thresholds: {
          query_count: ENV.fetch("LOAD_DIAGNOSTIC_QUERY_COUNT", 25).to_i,
          sql_ms: ENV.fetch("LOAD_DIAGNOSTIC_SQL_MS", 100).to_f,
          max_sql_ms: ENV.fetch("LOAD_DIAGNOSTIC_MAX_SQL_MS", 50).to_f,
          request_ms: ENV.fetch("LOAD_DIAGNOSTIC_REQUEST_MS", 500).to_f
        }
    end
  end
end
