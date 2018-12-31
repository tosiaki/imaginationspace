class AddDisplayNameAndEditingPasswordToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :display_name, :text
    add_column :articles, :editing_password_digest, :text
  end
end
