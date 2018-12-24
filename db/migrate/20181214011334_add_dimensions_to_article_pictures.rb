class AddDimensionsToArticlePictures < ActiveRecord::Migration[5.2]
  def change
    add_column :article_pictures, :width, :integer
    add_column :article_pictures, :height, :integer
  end
end
