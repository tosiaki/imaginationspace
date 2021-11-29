Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://youtube.com:80'
    resource 'youtube_video', headers: :any, methods: [:get, :post, :patch]
  end
end
