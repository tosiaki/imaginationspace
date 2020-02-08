class CreateIngredients < ActiveRecord::Migration[5.2]
  def change
    create_table :ingredients do |t|
      t.references :preparation, foreign_key: true
      t.references :item, foreign_key: true

      t.timestamps
    end
  end
end
