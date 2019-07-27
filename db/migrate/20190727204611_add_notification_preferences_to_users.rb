class AddNotificationPreferencesToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :notify_follow, :boolean, default: true
    add_column :users, :notify_kudos, :boolean, default: true
    add_column :users, :notify_bookmark, :boolean, default: true
    add_column :users, :notify_reply, :boolean, default: true
    add_column :users, :notify_signal_boost, :boolean, default: true
  end
end
