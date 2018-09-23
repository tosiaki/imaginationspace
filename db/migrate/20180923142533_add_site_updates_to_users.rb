class AddSiteUpdatesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :site_updates, :boolean, default: false
  end
end
