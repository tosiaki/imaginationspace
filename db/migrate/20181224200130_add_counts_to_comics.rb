class AddCountsToComics < ActiveRecord::Migration[5.2]
  def change
    add_column :comics, :kudos_count, :integer, default: 0
    add_column :comics, :bookmarks_count, :integer, default: 0
  end
end
