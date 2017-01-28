# == Schema Information
#
# Table name: moi_voice_live_stream_comments
#
#  id                        :integer          not null, primary key
#  moi_voice_twitcas_user_id :integer          not null
#  moi_voice_live_stream_id  :integer          not null
#  comment                   :text(65535)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  moi_voice_live_stream_comment_stream_index   (moi_voice_live_stream_id)
#  moi_voice_live_stream_comment_user_id_index  (moi_voice_twitcas_user_id)
#

require 'test_helper'

class MoiVoice::LiveStreamCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end