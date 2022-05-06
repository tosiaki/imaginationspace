class CreateTranslationPages < ActiveRecord::Migration[6.1]
  def change
    create_table :translation_pages do |t|
      t.text :filename
      t.references :translation, null: false, foreign_key: true
      t.references :translation_chapter
      t.integer :order

      t.timestamps
    end
  end
end
