class CreateArticleTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :article_taggings do |t|
      t.references :article_tag, foreign_key: true
      t.references :article, foreign_key: true

      t.timestamps
    end
  end
end
