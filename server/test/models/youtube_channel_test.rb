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
#  index_youtube_channels_on_published_at         (published_at)
#  index_youtube_channels_on_youtube_category_id  (youtube_category_id)
#

require 'test_helper'

class YoutubeChannelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
