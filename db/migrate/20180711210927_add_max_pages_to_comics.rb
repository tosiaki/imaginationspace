class AddMaxPagesToComics < ActiveRecord::Migration[5.2]
  def change
    add_column :comics, :max_pages, :integer, default: 1
  end
end
