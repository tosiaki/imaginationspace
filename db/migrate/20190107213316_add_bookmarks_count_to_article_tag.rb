class AddBookmarksCountToArticleTag < ActiveRecord::Migration[5.2]
  def change
    add_column :article_tags, :bookmarks_count, :integer, default: 0
  end
end
