class CreateSignalBoosts < ActiveRecord::Migration[5.2]
  def change
    create_table :signal_boosts do |t|
      t.references :post, foreign_key: true
      t.references :origin, foreign_key: true

      t.timestamps
    end
  end
end
