class CreateComics < ActiveRecord::Migration[5.2]
  def change
    create_table :comics do |t|
      t.string :title
      t.text :description
      t.references :user, foreign_key: true
      t.integer :pages
      t.integer :rating
      t.integer :front_page_rating

      t.timestamps
    end
  end
end
