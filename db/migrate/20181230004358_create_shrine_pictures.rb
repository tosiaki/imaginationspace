class CreateShrinePictures < ActiveRecord::Migration[5.2]
  def change
    create_table :shrine_pictures do |t|
      t.text :picture_data
    end
  end
end
