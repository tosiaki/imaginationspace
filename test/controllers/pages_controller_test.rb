require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "redirects the retired home page without indexing it" do
    get root_url

    assert_redirected_to "https://discord.gg/e97QGEA"
    assert_equal "public, max-age=86400", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
  end

  test "returns a quiet not found response for unsupported methods" do
    post "/articles"

    assert_response :not_found
    assert_empty response.body
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
  end

  test "returns a quiet cacheable gone response for retired legacy pages" do
    queries = count_database_queries { get "/articles/12345" }

    assert_response :gone
    assert_empty response.body
    assert_equal "0", response.headers["Content-Length"]
    assert_equal "public, max-age=86400", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
    assert_empty queries
  end

end
