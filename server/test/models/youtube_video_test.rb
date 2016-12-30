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
#  comment_count       :integer          default(0), not null
#  dislike_count       :integer          default(0), not null
#  like_count          :integer          default(0), not null
#  favorite_count      :integer          default(0), not null
#  view_count          :integer          default(0), not null
#
# Indexes
#
#  index_youtube_videos_on_comment_count       (comment_count)
#  index_youtube_videos_on_published_at        (published_at)
#  index_youtube_videos_on_video_id            (video_id) UNIQUE
#  index_youtube_videos_on_youtube_channel_id  (youtube_channel_id)
#

require 'test_helper'

class YoutubeVideoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
