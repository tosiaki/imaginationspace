class AddDisplayImageToArticle < ActiveRecord::Migration[5.2]
  def change
    add_column :articles, :display_image, :text
  end
end
