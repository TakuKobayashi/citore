# == Schema Information
#
# Table name: moi_voice_live_streams
#
#  id                        :integer          not null, primary key
#  moi_voice_twitcas_user_id :integer          not null
#  started_at                :datetime
#  finished_at               :datetime
#  state                     :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  moi_voice_live_finished_at_index      (started_at,finished_at)
#  moi_voice_live_streams_user_id_index  (moi_voice_twitcas_user_id,state)
#

require 'test_helper'

class MoiVoice::LiveStreamTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
