class CreateDiscordAttachments < ActiveRecord::Migration[6.1]
  def change
    create_table :discord_attachments do |t|
      t.bigint :discord_message_id
      t.text :content_type
      t.text :filename
      t.text :proxy_url
      t.text :url

      t.timestamps
    end
  end
end
