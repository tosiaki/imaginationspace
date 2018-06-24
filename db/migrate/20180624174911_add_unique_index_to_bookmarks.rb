class AddUniqueIndexToBookmarks < ActiveRecord::Migration[5.2]
  def change
    add_index :bookmarks, [:user_id, :bookmarkable_id, :bookmarkable_type], unique: true, name: 'user_bookmark_index'
  end
end
