class AddIconColumnsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :icon, :string
    add_column :users, :icon_alt, :string
    add_column :users, :icon_comment, :string
  end
end
