class AddReplyTimeToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :reply_time, :datetime
  end
end
