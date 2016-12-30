# == Schema Information
#
# Table name: youtube_video_tags
#
#  id               :integer          not null, primary key
#  youtube_video_id :integer          not null
#  tag              :string(255)      not null
#
# Indexes
#
#  index_youtube_video_tags_on_tag                       (tag)
#  index_youtube_video_tags_on_youtube_video_id_and_tag  (youtube_video_id,tag) UNIQUE
#

require 'test_helper'

class YoutubeVideoTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
