class CreateYoutubeVideoTags < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_video_tags do |t|
      t.integer :youtube_video_id, null: false
      t.string :tag, null: false
    end
    add_index :youtube_video_tags, [:youtube_video_id, :tag], unique: true
    add_index :youtube_video_tags, :tag
  end
end
