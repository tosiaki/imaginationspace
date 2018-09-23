class SubscriptionMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.confirmation.subject
  #
  def confirmation
    @greeting = "Subscription confirmation"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.subscription_mailer.notification.subject
  #
  def notification(work:, user:)
    @work = work
    @user = user
    mail to: user.email, subject: "New work posted on fancomics.org: #{work.title} by #{work.author}"
  end
end
