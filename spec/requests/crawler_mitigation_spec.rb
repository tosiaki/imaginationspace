require "rails_helper"

RSpec.describe "crawler mitigation", type: :request do
  before { Rails.application.reload_routes! }

  it "publishes a site-wide crawl prohibition" do
    get "/robots.txt"

    expect(response).to have_http_status(:ok)
    expect(response.media_type).to eq("text/plain")
    expect(response.body).to eq("User-agent: *\nDisallow: /\n")
    expect(Rails.root.join("public/robots.txt").read).to eq(CrawlerResponseHeaders::ROBOTS_BODY)
    expect(response.headers["X-Robots-Tag"]).to eq("noindex, nofollow, noarchive, nosnippet")
  end

  it "turns legacy GET paths into cacheable crawler-safe redirects" do
    get "/articles/old-crawler-target"

    expect(response).to redirect_to("https://discord.gg/e97QGEA")
    expect(response.headers["Cache-Control"]).to eq("public, max-age=86400")
    expect(response.headers["X-Robots-Tag"]).to eq("noindex, nofollow, noarchive, nosnippet")
  end

  it "does not redirect unsupported methods" do
    post "/articles/old-crawler-target"

    expect(response).to have_http_status(:not_found)
    expect(response.headers["X-Robots-Tag"]).to eq("noindex, nofollow, noarchive, nosnippet")
  end

  it "does not shadow framework-owned routes" do
    route = Rails.application.routes.recognize_path(
      "/rails/active_storage/blobs/example/file.png",
      method: :get
    )

    expect(route[:controller]).to eq("active_storage/blobs/redirect")
  end
end
