class AddCountsToDrawings < ActiveRecord::Migration[5.2]
  def change
    add_column :drawings, :kudos_count, :integer, default: 0
    add_column :drawings, :bookmarks_count, :integer, default: 0
  end
end
