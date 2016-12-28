class CreateYoutubeComments < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_comments do |t|
      t.integer :youtube_video_id
      t.integer :youtube_channel_id
      t.string :comment_id, null: false, default: ''
      t.text :comment
      t.integer :like_count, null: false, default: 0
      t.datetime :published_at
    end

    add_index :youtube_comments, :youtube_video_id
    add_index :youtube_comments, :youtube_channel_id
    add_index :youtube_comments, :comment_id, unique: true
  end
end
