class CreateDrawings < ActiveRecord::Migration[5.2]
  def change
    create_table :drawings do |t|
      t.string :title
      t.text :caption
      t.references :user, foreign_key: true
      t.string :drawing

      t.timestamps
    end
  end
end
