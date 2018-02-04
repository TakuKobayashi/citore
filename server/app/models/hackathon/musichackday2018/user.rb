# == Schema Information
#
# Table name: hackathon_musichackday2018_users
#
#  id               :integer          not null, primary key
#  token            :string(255)      not null
#  last_accessed_at :datetime         not null
#  user_agent       :text(65535)
#  options          :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_hackathon_musichackday2018_users_on_last_accessed_at  (last_accessed_at)
#  index_hackathon_musichackday2018_users_on_token             (token) UNIQUE
#

class Hackathon::Musichackday2018::User < ApplicationRecord
  serialize :options, JSON

  has_one :spotify, class_name: 'SpotifyAccount', as: :user
  has_one :sound_player, class_name: 'Hackathon::Musichackday2018::SoundPlayer', foreign_key: :user_id
  has_one :last_location, class_name: 'Hackathon::Musichackday2018::LastLocation', foreign_key: :user_id

  has_many :sound_logs, class_name: 'Hackathon::Musichackday2018::PlaySoundLog', foreign_key: :user_id
  has_many :location_logs, class_name: 'Hackathon::Musichackday2018::LocationLog', foreign_key: :user_id

  def sign_in!
    self.last_accessed_at = Time.current
    self.save!
  end

  def update_location!(lat:, lon:)
    last_location = nil
    transaction do
      log = self.location_logs.create!(lat: lat, lon: lon)
      last_location = Hackathon::Musichackday2018::LastLocation.find_or_initialize_by(user_id: self.id)
      last_location.update!(lat: lat, lon: lon, received_at: Time.current, log_id: log.id)
    end
    return last_location
  end

  def setup_sound_player!(audio_metum:)
    log = self.sound_logs.create!(
      state: :standby,
      sound: audio_metum
    )
    sound_player = Hackathon::Musichackday2018::SoundPlayer.find_or_initialize_by(user_id: self.id)
    sound_player.update!(state: :standby, log_id: log.id, sound_duration: 0, sound_played_at: nil)
    log.download_and_upload_file!
    sound_player.download!
    return sound_player
  end
end
