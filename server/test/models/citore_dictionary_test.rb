# == Schema Information
#
# Table name: citore_dictionaries
#
#  id            :integer          not null, primary key
#  tweet_id_str  :string(255)      not null
#  tweet_user_id :integer          not null
#  tweet         :string(255)      not null
#  tweet_reading :string(255)      not null
#  link_url      :text(65535)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_citore_dictionaries_on_tweet_id_str   (tweet_id_str) UNIQUE
#  index_citore_dictionaries_on_tweet_reading  (tweet_reading) UNIQUE
#

require 'test_helper'

class CitoreDictionaryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
