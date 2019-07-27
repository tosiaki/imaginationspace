# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/follow
  def follow
    @user = User.find(1)
    @followed = User.find(2)
    NotificationMailer.follow(@user, @followed)
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/kudos
  def kudos
    @submission = Article.find(250)
    @user = User.find(1)
    NotificationMailer.kudos(@submission, @user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/bookmark
  def bookmark
    @bookmarked = Article.find(250)
    @user = User.find(1)
    NotificationMailer.bookmark(@user, @bookmarked)
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/reply
  def reply
    @reply_to = Article.find(250)
    @reply = Article.find(2)
    @user = nil # User.find(1)
    NotificationMailer.reply(@reply_to, @reply, @user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/notification_mailer/signal_boost
  def signal_boost
    @boosted = Article.find(1)
    @user = User.find(1)
    NotificationMailer.signal_boost(@user, @boosted)
  end

end
