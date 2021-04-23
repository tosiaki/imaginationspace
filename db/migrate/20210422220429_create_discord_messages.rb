class CreateDiscordMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :discord_messages do |t|
      t.bigint :guild_id
      t.bigint :message_id
      t.text :user_name
      t.bigint :discord_user_id
      t.text :avatar_url
      t.datetime :message_created_at
      t.datetime :message_edited_at
      t.text :content
      t.bigint :reference

      t.timestamps
    end
  end
end
