class AddReplyToToArticles < ActiveRecord::Migration[5.2]
  def change
    add_reference :articles, :reply_to, foreign_key: { to_table: :articles }
  end
end
