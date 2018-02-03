# == Schema Information
#
# Table name: hackathon_musichackday2018_sound_players
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  state           :integer          default("standby"), not null
#  log_id          :integer          not null
#  sound_played_at :datetime
#  sound_duration  :float(24)        default(0.0), not null
#
# Indexes
#
#  index_hackathon_musichackday2018_sound_players_on_log_id   (log_id)
#  index_hackathon_musichackday2018_sound_players_on_user_id  (user_id)
#  musichackday2018_sound_players_sound_played_at_index       (sound_played_at)
#

require 'test_helper'

class Hackathon::Musichackday2018::SoundPlayerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
