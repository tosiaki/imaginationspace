require "test_helper"

class AuthenticationRoutesTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  setup do
    Users::SessionsController::LOGIN_RATE_LIMIT_STORE.clear
    Users::PasswordsController::RECOVERY_RATE_LIMIT_STORE.clear
    Users::ConfirmationsController::CONFIRMATION_RATE_LIMIT_STORE.clear
  end

  def log_in(user)
    post login_path, params: {
      user: { email: user.email, password: "password" }
    }
    follow_redirect!
  end

  test "serves a minimal uncached login page without application bundles" do
    get login_path

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
    assert_select 'meta[name="robots"][content="noindex, nofollow, noarchive, nosnippet"]'
    assert_select 'form[action="/login"][method="post"]'
    assert_select 'script[src*="packs"]', count: 0
    assert_select 'link[href*="authentication"][rel="stylesheet"]', count: 1
    assert_select 'link[href*="application"][rel="stylesheet"]', count: 0
    assert_select 'a[href="/signup"]', count: 0
    assert_select 'a[href="/reset_password"]', count: 1
    assert_select 'a[href="/resend_confirmation"]', count: 1
  end


  test "serves lightweight uncached account recovery forms" do
    get reset_password_path

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select 'form[action="/reset_password"][method="post"]'
    assert_select 'link[href*="authentication"][rel="stylesheet"]', count: 1
    assert_select 'script[src*="packs"]', count: 0

    get resend_confirmation_path

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select 'form[action="/resend_confirmation"][method="post"]'
  end

  test "does not reveal whether a recovery email exists" do
    post reset_password_path, params: { user: { email: "missing@example.test" } }

    assert_redirected_to login_path
    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "sends an existing user a working password reset link" do
    assert_emails 1 do
      post reset_password_path, params: { user: { email: users(:one).email } }
    end

    message = ActionMailer::Base.deliveries.last
    link = Nokogiri::HTML(message.html_part&.body&.decoded || message.body.decoded)
      .at_css('a[href*="/reset_password/edit"]')
    assert link

    get URI(link["href"]).request_uri

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_select 'form[action="/reset_password"]'
    assert_select 'input[name="user[reset_password_token]"]', count: 1
  end

  test "rate limits repeated password recovery mail requests" do
    5.times do
      post reset_password_path, params: { user: { email: "missing@example.test" } }
      assert_not_equal 429, response.status
    end

    post reset_password_path, params: { user: { email: "missing@example.test" } }

    assert_response :too_many_requests
  end

  test "allows a confirmed existing user to log in and out" do
    post login_path, params: {
      user: { email: users(:one).email, password: "password" }
    }

    assert_redirected_to account_path

    delete logout_path

    assert_redirected_to root_path
  end

  test "requires authentication for the account page" do
    queries = count_database_queries { get account_path }

    assert_redirected_to login_path
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_empty queries
  end

  test "serves only the signed-in user's uncached account form without application bundles" do
    log_in users(:one)

    queries = count_database_queries { get account_path }

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
    assert_select 'form[action="/account"][method="post"]'
    assert_select 'input[name="_method"][value="patch"]'
    assert_select 'input[name="user[email]"]', count: 0
    assert_select 'input[name="user[password]"]', count: 0
    assert_select 'link[href*="authentication"][rel="stylesheet"]', count: 1
    assert_select 'link[href*="application"][rel="stylesheet"]', count: 0
    assert_select 'a[href="/account/upload-smoke-test"]', count: 1
    assert_select 'script[src*="packs"]', count: 0
    assert_operator queries.length, :<=, 1, "account GET exceeded its query budget: #{queries.inspect}"
  end

  test "updates only permitted fields on the signed-in user's account" do
    log_in users(:one)

    queries = count_database_queries do
      patch account_path, params: {
        user: {
          name: "Updated name",
          title: "Updated title",
          email: "replaced@example.test",
          guest: true
        }
      }
    end

    assert_redirected_to account_path
    users(:one).reload
    assert_equal "Updated name", users(:one).name
    assert_equal "Updated title", users(:one).title
    assert_not_equal "replaced@example.test", users(:one).email
    assert_not users(:one).guest?
    assert_operator queries.length, :<=, 2, "account PATCH exceeded its query budget: #{queries.inspect}"
  end

  test "keeps public content retired while requiring authentication for uploads" do
    get "/articles"
    assert_response :gone
    assert_empty response.body

    post "/s3/params", params: { method: "PUT" }
    assert_redirected_to login_path
    assert_empty response.body

    get "/s3/params"
    assert_response :gone
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
