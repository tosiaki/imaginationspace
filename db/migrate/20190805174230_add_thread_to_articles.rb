class AddThreadToArticles < ActiveRecord::Migration[5.2]
  def change
    add_reference :articles, :thread, foreign_key: { to_table: :articles }
  end
end
