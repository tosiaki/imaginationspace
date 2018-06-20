class AddRatingToDrawing < ActiveRecord::Migration[5.2]
  def change
    add_column :drawings, :rating, :integer, default: 0
  end
end
