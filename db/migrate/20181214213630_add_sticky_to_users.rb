class AddStickyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :sticky, foreign_key: { to_table: :articles }
  end
end
