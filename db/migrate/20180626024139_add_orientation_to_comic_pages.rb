class AddOrientationToComicPages < ActiveRecord::Migration[5.2]
  def change
    add_column :comic_pages, :orientation, :integer, default: 0
  end
end
