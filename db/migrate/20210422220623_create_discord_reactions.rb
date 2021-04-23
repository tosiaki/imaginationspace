class CreateDiscordReactions < ActiveRecord::Migration[6.1]
  def change
    create_table :discord_reactions do |t|
      t.bigint :discord_message_id
      t.integer :count
      t.text :emoji_name
      t.bigint :emoji_id
      t.text :emoji_url

      t.timestamps
    end
  end
end
