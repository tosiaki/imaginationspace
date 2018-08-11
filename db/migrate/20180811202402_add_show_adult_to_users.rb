class AddShowAdultToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :show_adult, :boolean, default: false
  end
end
