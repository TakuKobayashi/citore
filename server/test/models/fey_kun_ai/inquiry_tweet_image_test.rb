# == Schema Information
#
# Table name: fey_kun_ai_inquiry_tweet_images
#
#  id               :integer          not null, primary key
#  inquiry_tweet_id :string(255)      not null
#  image_url        :string(255)      not null
#  file_path        :string(255)
#  exifs            :text(65535)
#  checksum         :string(255)      not null
#  output           :text(65535)
#
# Indexes
#
#  fka_inquiry_image_id_url_index  (inquiry_tweet_id,image_url)
#

require 'test_helper'

class FeyKunAi::InquiryTweetImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
