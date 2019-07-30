class Bookmark < ApplicationRecord
  belongs_to :bookmarkable, polymorphic: true, counter_cache: true
  belongs_to :user, inverse_of: :bookmarks

  after_create :notify_user

  def notify_user
    if bookmarkable_type == "User"
      if bookmarkable.notify_follow
        NotificationMailer.follow(user, bookmarkable).deliver_now
      end
    elsif bookmarkable_type == "Article"
      if bookmarkable.user && bookmarkable.user.notify_bookmark
        NotificationMailer.bookmark(user, bookmarkable).deliver_now
      end
    end
  end
end
