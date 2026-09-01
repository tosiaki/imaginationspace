require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["SELENIUM_REMOTE_URL"]
    Capybara.register_driver :remote_headless_chrome do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--headless=new")
      options.add_argument("--window-size=1400,1400")

      Capybara::Selenium::Driver.new(app, browser: :remote,
        url: ENV.fetch("SELENIUM_REMOTE_URL"), options: options)
    end
    driven_by :remote_headless_chrome
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
  end
end
