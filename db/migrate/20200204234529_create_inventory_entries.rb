class CreateInventoryEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :inventory_entries do |t|
      t.references :user, foreign_key: true
      t.references :item, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end
end
