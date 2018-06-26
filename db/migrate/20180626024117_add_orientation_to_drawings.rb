class AddOrientationToDrawings < ActiveRecord::Migration[5.2]
  def change
    add_column :drawings, :orientation, :integer, default: 0
  end
end
