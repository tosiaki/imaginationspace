require "test_helper"
require Rails.root.join("config/sendgrid_smtp_settings")

class SendgridSmtpSettingsTest < ActiveSupport::TestCase
  test "prefers a SendGrid API key for SMTP authentication" do
    settings = SendgridSmtpSettings.from_environment(
      "SENDGRID_API_KEY" => "replacement-key",
      "SENDGRID_USERNAME" => "legacy-user",
      "SENDGRID_PASSWORD" => "legacy-password"
    )

    assert_equal "apikey", settings[:user_name]
    assert_equal "replacement-key", settings[:password]
  end

  test "uses legacy add-on credentials until an API key is supplied" do
    settings = SendgridSmtpSettings.from_environment(
      "SENDGRID_USERNAME" => "legacy-user",
      "SENDGRID_PASSWORD" => "legacy-password"
    )

    assert_equal "legacy-user", settings[:user_name]
    assert_equal "legacy-password", settings[:password]
  end

  test "uses numeric SMTP port" do
    settings = SendgridSmtpSettings.from_environment({})

    assert_equal 587, settings[:port]
  end
end
