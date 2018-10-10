class RemoveOrientationFromDrawings < ActiveRecord::Migration[5.2]
  def change
    remove_column :drawings, :orientation, :integer
  end
end
