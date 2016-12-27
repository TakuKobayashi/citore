# == Schema Information
#
# Table name: youtube_channels
#
#  id                    :integer          not null, primary key
#  youtube_category_id   :integer
#  channel_id            :string(255)      default(""), not null
#  title                 :string(255)      default(""), not null
#  description           :text(65535)
#  comment_count         :integer          default(0), not null
#  subscriber_count      :integer          default(0), not null
#  video_count           :integer          default(0), not null
#  view_count            :integer          default(0), not null
#  thumnail_image_url    :string(255)      default(""), not null
#  banner_image_url_json :text(65535)
#  published_at          :datetime
#
# Indexes
#
#  index_youtube_channels_on_published_at         (published_at)
#  index_youtube_channels_on_youtube_category_id  (youtube_category_id)
#

class YoutubeChannel < YoutubeRecord
  belongs_to :category, class_name: 'YoutubeCategory', foreign_key: :youtube_category_id
  has_many :videos, class_name: 'YoutubeVideo', foreign_key: :youtube_channel_id
  has_many :comments, class_name: 'YoutubeComment', foreign_key: :youtube_video_id
end
