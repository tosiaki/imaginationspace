class AddListingQueryIndexes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :discord_messages, :message_created_at, algorithm: :concurrently
    add_index :discord_reactions, :discord_message_id, algorithm: :concurrently
    add_index :discord_embeds, :discord_message_id, algorithm: :concurrently
    add_index :discord_attachments, :discord_message_id, algorithm: :concurrently
    add_index :statuses, :timeline_time, algorithm: :concurrently
    add_index :articles, :reply_time, algorithm: :concurrently
    add_index :article_taggings, [:article_id, :article_tag_id], unique: true, algorithm: :concurrently
  end
end
