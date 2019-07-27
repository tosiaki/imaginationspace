class NotificationMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.follow.subject
  #
  def follow(user, bookmarkable)
    @followed = bookmarkable
    @user = user
    mail to: @followed.email, subject: "#{@user.name} is now following you"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.kudos.subject
  #
  def kudos(submission, user=nil)
    @submission = submission
    @user = user
    mail to: @submission.user.email, subject: "#{@user ? @user.name : 'A guest'} gave kudos to #{@submission.title.present? ? @submission.title : 'your submission'}"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.bookmark.subject
  #
  def bookmark(user, bookmarkable)
    @bookmarked = bookmarkable
    @user = user
    mail to: @bookmarked.user.email, subject: "#{@user.name} just bookmarked #{@bookmarked.title.present? ? @bookmarked.title : 'your submission'}"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.reply.subject
  #
  def reply(reply_to, reply, user=nil)
    @reply_to = reply_to
    @reply = reply
    @user = user

    mail to: @reply_to.user.email, subject: "#{@user ? @user.name : 'A guest'} just replied to #{@reply_to.title.present? ? @reply_to.title : 'your submission'}"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notification_mailer.signal_boost.subject
  #
  def signal_boost(user, boosted)
    @boosted = boosted
    @user = user

    mail to: @boosted.user.email, subject: "#{@user.name} just signal boosted #{@boosted.title.present? ? @boosted.title : 'your submission'}"
  end
end
