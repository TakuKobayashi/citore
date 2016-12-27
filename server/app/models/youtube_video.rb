# == Schema Information
#
# Table name: youtube_videos
#
#  id                 :integer          not null, primary key
#  video_id           :string(255)      default(""), not null
#  youtube_channel_id :integer
#  title              :string(255)      default(""), not null
#  description        :text(65535)
#  thumnail_image_url :string(255)      default(""), not null
#  published_at       :datetime
#
# Indexes
#
#  index_youtube_videos_on_published_at        (published_at)
#  index_youtube_videos_on_youtube_channel_id  (youtube_channel_id)
#

class YoutubeVideo < YoutubeRecord
end
