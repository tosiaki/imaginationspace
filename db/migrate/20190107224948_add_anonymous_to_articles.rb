class AddAnonymousToArticles < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :anonymous, :boolean, default: false
  end
end
