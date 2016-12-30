# == Schema Information
#
# Table name: youtube_comments
#
#  id                 :integer          not null, primary key
#  youtube_video_id   :integer
#  youtube_channel_id :integer
#  comment_id         :string(255)      default(""), not null
#  comment            :text(65535)
#  like_count         :integer          default(0), not null
#  published_at       :datetime
#
# Indexes
#
#  index_youtube_comments_on_comment_id          (comment_id) UNIQUE
#  index_youtube_comments_on_youtube_channel_id  (youtube_channel_id)
#  index_youtube_comments_on_youtube_video_id    (youtube_video_id)
#

class YoutubeComment < YoutubeRecord
  #belongs_to :video, class_name: 'YoutubeVideo', foreign_key: :youtube_video_id
  #belongs_to :channel, class_name: 'YoutubeChannel', foreign_key: :youtube_channel_id

  def self.import_comment!(youtube_comment_thread, video_id: nil, channel_id: nil)
    comments = youtube_comment_thread.items.map do |item|
      comment = YoutubeComment.new(
        youtube_video_id: video_id,
        youtube_channel_id: channel_id,
        comment_id: item.id,
        published_at: item.snippet.top_level_comment.snippet.published_at,
        comment: TweetVoiceSeedDynamo.sanitized(item.snippet.top_level_comment.snippet.text_display),
        like_count: item.snippet.top_level_comment.snippet.like_count
      )
      comment
    end
    updates = [:published_at]
    updates << :youtube_channel_id if channel_id.present?
    updates <<  :youtube_video_id if video_id.present?
    YoutubeComment.import(comments, on_duplicate_key_update: updates)
  end
end
