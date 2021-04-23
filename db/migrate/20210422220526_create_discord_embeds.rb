class CreateDiscordEmbeds < ActiveRecord::Migration[6.1]
  def change
    create_table :discord_embeds do |t|
      t.bigint :discord_message_id
      t.text :description
      t.text :url
      t.text :footer_text
      t.text :footer_icon_url
      t.text :image_url
      t.text :image_proxy_url
      t.text :video_url

      t.timestamps
    end
  end
end
