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

class Hackathon::Musichackday2018::SoundPlayer < ApplicationRecord
  belongs_to :log, class_name: 'Hackathon::Musichackday2018::PlaySoundLog', foreign_key: :log_id, required: false

  enum state: {
    standby: 0,
    download: 1,
    playing: 2,
    complete: 3
  }

  def play!
    transaction do
      update!(state: :playing, sound_played_at: Time.current)
      log.playing!
    end
  end
end
