require "test_helper"
require "stringio"

class UploadSmokeTestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Users::SessionsController::LOGIN_RATE_LIMIT_STORE.clear
    @key = "uploads/c56a4180-65aa-42ec-a945-5fd21dec0538.png"
    @bytes = "smoke-test-image-bytes"
  end

  teardown do
    Shrine.storages[:cache].delete(@key) if Shrine.storages[:cache].exists?(@key)
  end

  test "requires authentication without querying the database" do
    queries = count_database_queries { get upload_smoke_test_path }

    assert_redirected_to login_path
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_empty queries
  end

  test "serves the uncached smoke-test uploader to an authenticated user" do
    log_in(users(:one))

    queries = count_database_queries { get upload_smoke_test_path }

    assert_response :success
    assert_equal "no-store", response.headers["Cache-Control"]
    assert_equal "noindex, nofollow, noarchive, nosnippet", response.headers["X-Robots-Tag"]
    assert_select 'input[type="file"][data-upload-smoke-test]', count: 1
    assert_select 'script[src*="upload_smoke_test"]', minimum: 1
    assert_operator queries.length, :<=, 1
  end

  test "verifies and deletes an authorized uploaded object" do
    user = users(:one)
    log_in(user)
    Shrine.storages[:cache].upload(StringIO.new(@bytes), @key)

    post verify_upload_smoke_test_path, params: authorized_parameters(user), as: :json

    assert_response :success
    assert_equal "verified_and_deleted", response.parsed_body.fetch("status")
    assert_not Shrine.storages[:cache].exists?(@key)
  end

  test "does not verify another user's authorization" do
    log_in(users(:one))
    Shrine.storages[:cache].upload(StringIO.new(@bytes), @key)

    post verify_upload_smoke_test_path, params: authorized_parameters(users(:two)), as: :json

    assert_response :unprocessable_content
    assert Shrine.storages[:cache].exists?(@key)
  end

  private

  def log_in(user)
    post login_path, params: { user: { email: user.email, password: "password" } }
    follow_redirect!
  end

  def authorized_parameters(user)
    {
      key: @key,
      size: @bytes.bytesize,
      authorization: Rails.application.message_verifier(:direct_upload_authorization).generate(
        { user_id: user.id, key: @key, size: @bytes.bytesize },
        expires_in: DirectUploadSigner::URL_LIFETIME
      )
    }
  end
end
