# == Schema Information
#
# Table name: youtube_videos
#
#  id                  :integer          not null, primary key
#  video_id            :string(255)      default(""), not null
#  youtube_channel_id  :integer
#  youtube_category_id :integer
#  title               :string(255)      default(""), not null
#  description         :text(65535)
#  thumnail_image_url  :string(255)      default(""), not null
#  published_at        :datetime
#
# Indexes
#
#  index_youtube_videos_on_published_at         (published_at)
#  index_youtube_videos_on_video_id             (video_id) UNIQUE
#  index_youtube_videos_on_youtube_category_id  (youtube_category_id)
#  index_youtube_videos_on_youtube_channel_id   (youtube_channel_id)
#

class YoutubeVideo < YoutubeRecord
  #belongs_to :channel, class_name: 'YoutubeChannel', foreign_key: :youtube_channel_id
  has_many :comments, class_name: 'YoutubeComment', foreign_key: :youtube_video_id

  def self.import_video!(youtube_video, category_id: nil, channel_id: nil)
    videos = youtube_video.items.map do |item|
      video = YoutubeVideo.new(
        youtube_category_id: category_id,
        youtube_channel_id: channel_id,
        video_id: item.id.video_id,
        title: item.snippet.title,
        description: item.snippet.description,
        published_at: item.snippet.published_at,
        thumnail_image_url: item.snippet.thumbnails.default.url
      )
      video
    end
    updates = [:published_at]
    updates << :youtube_channel_id if channel_id.present?
    updates <<  :youtube_category_id if category_id.present?
    YoutubeVideo.import(videos, on_duplicate_key_update: updates)
  end
end
