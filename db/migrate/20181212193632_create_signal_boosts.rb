class CreateSignalBoosts < ActiveRecord::Migration[5.2]
  def change
    create_table :signal_boosts do |t|
      t.references :origin, foreign_key: { to_table: :articles }

      t.timestamps
    end
  end
end
