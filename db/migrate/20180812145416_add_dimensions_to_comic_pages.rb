class AddDimensionsToComicPages < ActiveRecord::Migration[5.2]
  def change
    add_column :comic_pages, :width, :integer
    add_column :comic_pages, :height, :integer
  end
end
