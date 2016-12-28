class CreateYoutubeVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_videos do |t|
      t.string :video_id, null: false, default: ''
      t.integer :youtube_channel_id
      t.string :title, null: false, default: ''
      t.text :description
      t.string :thumnail_image_url, null: false, default: ''
      t.datetime :published_at
    end

    add_index :youtube_videos, :youtube_channel_id
    add_index :youtube_videos, :published_at
    add_index :youtube_videos, :video_id, unique: true
  end
end
