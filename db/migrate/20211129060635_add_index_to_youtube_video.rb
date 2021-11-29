class AddIndexToYoutubeVideo < ActiveRecord::Migration[6.1]
  def change
    add_index :youtube_videos, :url, unique: true
  end
end
