# == Schema Information
#
# Table name: youtube_channels
#
#  id                  :integer          not null, primary key
#  youtube_category_id :integer
#  channel_id          :string(255)      default(""), not null
#  title               :string(255)      default(""), not null
#  description         :text(65535)
#  comment_count       :integer          default(0), not null
#  subscriber_count    :integer          default(0), not null
#  video_count         :integer          default(0), not null
#  view_count          :integer          default(0), not null
#  thumnail_image_url  :string(255)      default(""), not null
#  published_at        :datetime
#
# Indexes
#
#  index_youtube_channels_on_channel_id           (channel_id) UNIQUE
#  index_youtube_channels_on_comment_count        (comment_count)
#  index_youtube_channels_on_published_at         (published_at)
#  index_youtube_channels_on_youtube_category_id  (youtube_category_id)
#

class YoutubeChannel < YoutubeRecord
  #belongs_to :category, class_name: 'YoutubeCategory', foreign_key: :youtube_category_id
  has_many :videos, class_name: 'YoutubeVideo', foreign_key: :youtube_channel_id
  has_many :comments, class_name: 'YoutubeComment', foreign_key: :youtube_video_id

  def self.import_channel!(youtube_channel, category_id: nil)
    channels = youtube_channel.items.map do |item|
      cannel = YoutubeChannel.new(
        youtube_category_id: category_id,
        channel_id: item.id,
        title: Sanitizer.basic_sanitize(item.snippet.title),
        description: Sanitizer.basic_sanitize(item.snippet.description),
        published_at: item.snippet.published_at,
        thumnail_image_url: item.snippet.thumbnails.default.url,
        comment_count: item.statistics.comment_count,
        subscriber_count: item.statistics.subscriber_count,
        video_count: item.statistics.video_count,
        view_count: item.statistics.view_count
        )
      cannel
    end
    YoutubeChannel.import(channels, on_duplicate_key_update: [:youtube_category_id])
  end
end
