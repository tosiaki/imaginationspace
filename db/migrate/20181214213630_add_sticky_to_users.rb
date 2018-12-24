class AddStickyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :sticky, foreign_key: true
  end
end
