class AddTagEditorToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :tag_editor, :boolean, default: false
  end
end
