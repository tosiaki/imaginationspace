class CreateTranslationChapters < ActiveRecord::Migration[6.1]
  def change
    create_table :translation_chapters do |t|
      t.text :title
      t.references :translation, null: false, foreign_key: true
      t.integer :order

      t.timestamps
    end
  end
end
