class AddPageIdAndInlinePictureToShrinePictures < ActiveRecord::Migration[5.2]
  def change
    add_reference :shrine_pictures, :page, polymorphic: true
    add_column :shrine_pictures, :inline_picture, :boolean, default: false
  end
end
