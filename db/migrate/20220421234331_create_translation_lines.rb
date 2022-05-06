class CreateTranslationLines < ActiveRecord::Migration[6.1]
  def change
    create_table :translation_lines do |t|
      t.references :translation_page, null: false, foreign_key: true
      t.text :original
      t.text :translation
      t.integer :order

      t.timestamps
    end
  end
end
