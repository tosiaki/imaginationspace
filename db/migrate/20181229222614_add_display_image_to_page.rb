class AddDisplayImageToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :display_image, :text
  end
end
