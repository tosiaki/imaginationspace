class RemoveOrientationFromComicPages < ActiveRecord::Migration[5.2]
  def change
    remove_column :comic_pages, :orientation, :integer
  end
end
