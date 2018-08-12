class AddDimensionsToDrawings < ActiveRecord::Migration[5.2]
  def change
    add_column :drawings, :width, :integer
    add_column :drawings, :height, :integer
  end
end
