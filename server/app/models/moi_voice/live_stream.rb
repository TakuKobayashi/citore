# == Schema Information
#
# Table name: moi_voice_live_streams
#
#  id                        :integer          not null, primary key
#  moi_voice_twitcas_user_id :integer          not null
#  start_at                  :datetime         not null
#  state                     :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  moi_voice_live_streams_user_id_index  (moi_voice_twitcas_user_id)
#

class MoiVoice::LiveStream < ApplicationRecord
end
