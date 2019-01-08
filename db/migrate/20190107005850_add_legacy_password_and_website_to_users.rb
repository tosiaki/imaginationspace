class AddLegacyPasswordAndWebsiteToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :legacy_password, :integer, defualt: 0
    add_column :users, :website, :text
  end
end
