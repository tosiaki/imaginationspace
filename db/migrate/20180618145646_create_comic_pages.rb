class CreateComicPages < ActiveRecord::Migration[5.2]
  def change
    create_table :comic_pages do |t|
      t.references :comic, foreign_key: true
      t.integer :page, default: 1
      t.string :drawing

      t.timestamps
    end
  end
end
