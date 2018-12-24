class AddCommentToSignalBoosts < ActiveRecord::Migration[5.2]
  def change
    add_column :signal_boosts, :comment, :text
  end
end
