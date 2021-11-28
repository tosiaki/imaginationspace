class CreateYoutubeVideos < ActiveRecord::Migration[6.1]
  def change
    create_table :youtube_videos do |t|
      t.text :url
      t.text :title
      t.boolean :watched, default: false
      t.timestamp :date_watched

      t.timestamps
    end
  end
end
