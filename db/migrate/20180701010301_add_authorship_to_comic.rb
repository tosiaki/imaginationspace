class AddAuthorshipToComic < ActiveRecord::Migration[5.2]
  def change
    add_column :comics, :authorship, :integer, default: 0
  end
end
