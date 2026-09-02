require "test_helper"

class AuthenticationRoutesTest < ActionDispatch::IntegrationTest
  setup do
    Users::SessionsController::LOGIN_RATE_LIMIT_STORE.clear
  end

  test "serves a minimal uncached login page without application bundles" do
    get login_path

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
    assert_select 'meta[name="robots"][content="noindex, nofollow, noarchive, nosnippet"]'
    assert_select 'form[action="/login"][method="post"]'
    assert_select 'script[src*="packs"]', count: 0
    assert_select 'a[href="/signup"]', count: 0
    assert_select 'a[href="/reset_password"]', count: 0
  end

  test "allows a confirmed existing user to log in and out" do
    post login_path, params: {
      user: { email: users(:one).email, password: "password" }
    }

    assert_redirected_to root_path

    delete logout_path

    assert_redirected_to root_path
  end

  test "keeps content and upload routes retired" do
    get "/articles"
    assert_redirected_to "https://discord.gg/e97QGEA"

    post "/s3/params", params: { method: "PUT" }
    assert_response :not_found
    assert_empty response.body
  end

  test "rate limits repeated login attempts before they can amplify CPU load" do
    10.times do
      post login_path, params: {
        user: { email: "missing@example.test", password: "incorrect" }
      }
      assert_not_equal 429, response.status
    end

    post login_path, params: {
      user: { email: "missing@example.test", password: "incorrect" }
    }

    assert_response :too_many_requests
  end
end
