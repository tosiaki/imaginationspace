class AddArticleTagLookupIndex < ActiveRecord::Migration[8.1]
  def change
    add_index :article_tags, [:context, :name], name: "index_article_tags_on_context_and_name"
  end
end
