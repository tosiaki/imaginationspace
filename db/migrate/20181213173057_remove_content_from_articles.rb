class RemoveContentFromArticles < ActiveRecord::Migration[5.2]
  def change
    remove_column :articles, :content, :text
  end
end
