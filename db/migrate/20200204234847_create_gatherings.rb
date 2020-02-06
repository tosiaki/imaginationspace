class CreateGatherings < ActiveRecord::Migration[5.2]
  def change
    create_table :gatherings do |t|
      t.references :item, foreign_key: true
      t.float :delay

      t.timestamps
    end
  end
end
