class AddUniqueIndexToKudos < ActiveRecord::Migration[5.2]
  def change
    add_index :kudos, [:user_id, :work_id, :work_type], unique: true, name: 'user_kudos_index'
  end
end
