class CreateDiscordUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :discord_users do |t|
      t.bigint :user_id
      t.text :user_name
      t.text :user_display_name

      t.timestamps
    end
  end
end
