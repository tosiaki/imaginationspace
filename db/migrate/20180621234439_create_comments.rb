class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.references :user, foreign_key: true
      t.references :commentable, polymorphic: true, index: true
      t.references :work, polymorphic: true, index: true
      t.string :name
      t.string :email
      t.text :content

      t.timestamps
    end
  end
end
