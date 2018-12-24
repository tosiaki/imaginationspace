class AddReplyToToArticles < ActiveRecord::Migration[5.2]
  def change
    add_reference :articles, :reply_to, foreign_key: true
  end
end
