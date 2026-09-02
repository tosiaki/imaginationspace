require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @original_legacy_salt = ENV["LEGACY_SALT"]
    ENV["LEGACY_SALT"] = "test legacy salt"
  end

  teardown do
    ENV["LEGACY_SALT"] = @original_legacy_salt
  end

  test "a valid legacy password migrates the user to Devise authentication" do
    user = users(:one)
    password = "legacy password"
    user.update_columns(legacy_password: 1)
    create_legacy_credential(user, password)

    assert user.valid_password?(password)
    assert_equal 0, user.reload.legacy_password
    assert user.valid_password?(password)
  end

  test "an invalid legacy password does not migrate the user" do
    user = users(:one)
    user.update_columns(legacy_password: 1)
    create_legacy_credential(user, "correct password")

    assert_not user.valid_password?("wrong password")
    assert_equal 1, user.reload.legacy_password
  end

  test "a missing legacy credential fails authentication without raising" do
    user = users(:one)
    user.update_columns(legacy_password: 1)
    user.legacy_user&.destroy!

    assert_not user.valid_password?("password")
    assert_equal 1, user.reload.legacy_password
  end

  private

  def create_legacy_credential(user, password)
    username = "legacy-user"
    digest = Digest::SHA256.base64digest(username + password + ENV.fetch("LEGACY_SALT"))[0..-2]

    user.create_legacy_user!(legacy_username: username, legacy_password_digest: digest)
  end
end
