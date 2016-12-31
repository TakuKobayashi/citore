class AddYoutubeVideoToCommentCountColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :youtube_videos, :comment_count, :integer, null: false, default: 0
    add_index :youtube_videos, :comment_count
  end
end
