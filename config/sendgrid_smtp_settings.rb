module SendgridSmtpSettings
  def self.from_environment(environment = ENV)
    api_key = environment["SENDGRID_API_KEY"]
    api_key = nil if api_key&.empty?

    {
      address: "smtp.sendgrid.net",
      port: 587,
      authentication: :plain,
      user_name: api_key ? "apikey" : environment["SENDGRID_USERNAME"],
      password: api_key || environment["SENDGRID_PASSWORD"],
      domain: "heroku.com",
      enable_starttls_auto: true
    }
  end
end
