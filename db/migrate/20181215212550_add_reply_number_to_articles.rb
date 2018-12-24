class AddReplyNumberToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :reply_number, :integer, default: 0
  end
end
