require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "redirects the retired home page without indexing it" do
    get root_url

    assert_redirected_to "https://discord.gg/e97QGEA"
    assert_equal "public, max-age=86400", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
  end

end
