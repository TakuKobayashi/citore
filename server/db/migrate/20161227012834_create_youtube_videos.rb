class CreateYoutubeVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_videos do |t|
      t.string :video_id, null: false, default: ''
      t.integer :youtube_channel_id
      t.integer :youtube_category_id
      t.string :title, null: false, default: ''
      t.text :description
      t.string :thumnail_image_url, null: false, default: ''
      t.datetime :published_at
      t.integer :comment_count, null: false, default: 0
      t.integer :dislike_count, null: false, default: 0
      t.integer :like_count, null: false, default: 0
      t.integer :favorite_count, null: false, default: 0
      t.integer :view_count, null: false, default: 0, limit: 8
    end

    add_index :youtube_videos, :youtube_channel_id
    add_index :youtube_videos, :comment_count
    add_index :youtube_videos, :published_at
    add_index :youtube_videos, :video_id, unique: true
  end
end
