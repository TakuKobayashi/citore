class CreateYoutubeVideoRelateds < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_video_relateds do |t|
      t.integer :youtube_video_id, null: false
      t.integer :to_youtube_video_id, null: false
    end
    add_index :youtube_video_relateds, :youtube_video_id
    add_index :youtube_video_relateds, :to_youtube_video_id
  end
end
