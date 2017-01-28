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

class MoiVoice::LiveStream < ApplicationRecord
  enum state: [:stay, :playing, :finish]
  has_many :comments, class_name: 'MoiVoice::LiveStreamComment', foreign_key: :moi_voice_live_stream_id
end
