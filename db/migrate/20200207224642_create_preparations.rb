class CreatePreparations < ActiveRecord::Migration[5.2]
  def change
    create_table :preparations do |t|
      t.text :name
      t.references :product, foreign_key: { to_table: :items }
      t.float :time_required

      t.timestamps
    end
  end
end
