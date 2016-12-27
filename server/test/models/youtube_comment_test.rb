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
#  index_youtube_comments_on_youtube_channel_id  (youtube_channel_id)
#  index_youtube_comments_on_youtube_video_id    (youtube_video_id)
#

require 'test_helper'

class YoutubeCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
