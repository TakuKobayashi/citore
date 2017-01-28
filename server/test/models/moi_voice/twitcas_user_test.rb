# == Schema Information
#
# Table name: moi_voice_twitcas_users
#
#  id                      :integer          not null, primary key
#  twitcas_user_id         :string(255)      not null
#  twitcast_uesr_screen_id :string(255)      not null
#  name                    :string(255)
#  access_token            :text(65535)
#  expires_in              :integer          default(0), not null
#  last_logined_at         :datetime         not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_moi_voice_twitcas_users_on_twitcas_user_id          (twitcas_user_id) UNIQUE
#  index_moi_voice_twitcas_users_on_twitcast_uesr_screen_id  (twitcast_uesr_screen_id) UNIQUE
#

require 'test_helper'

class MoiVoice::TwitcasUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
