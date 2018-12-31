class AddBookmarksCountToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :bookmarks_count, :integer, default: 0
  end
end
