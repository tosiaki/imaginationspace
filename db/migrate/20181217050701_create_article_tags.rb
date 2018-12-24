class CreateArticleTags < ActiveRecord::Migration[5.2]
  def change
    create_table :article_tags do |t|
      t.text :name
      t.text :context

      t.timestamps
    end
  end
end
