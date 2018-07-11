class AddPageAdditionToComics < ActiveRecord::Migration[5.2]
  def change
    add_column :comics, :page_addition, :datetime
  end
end
