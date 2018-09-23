# Preview all emails at http://localhost:3000/rails/mailers/subscription_mailer
class SubscriptionMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/subscription_mailer/confirmation
  def confirmation
    SubscriptionMailer.confirmation
  end

  # Preview this email at http://localhost:3000/rails/mailers/subscription_mailer/notification
  def notification
    user = User.first
    comic = Comic.first
    SubscriptionMailer.notification(work: comic, user: user)
  end

end
