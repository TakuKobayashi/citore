# == Schema Information
#
# Table name: twitter_bots
#
#  id                   :integer          not null, primary key
#  type                 :string(255)      not null
#  action               :integer          not null
#  action_value         :string(255)      not null
#  action_resource_path :string(255)
#  action_id            :string(255)      not null
#  action_time          :datetime         not null
#  action_from_id       :integer
#
# Indexes
#
#  index_twitter_bots_on_action_from_id   (action_from_id)
#  index_twitter_bots_on_action_id        (action_id)
#  index_twitter_bots_on_type_and_action  (type,action)
#

require 'test_helper'

class TwitterBotTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
