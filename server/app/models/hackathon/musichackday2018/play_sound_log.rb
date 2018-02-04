# == Schema Information
#
# Table name: hackathon_musichackday2018_play_sound_logs
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  state         :integer          default("standby"), not null
#  sound_type    :string(255)      not null
#  sound_id      :integer          not null
#  next_sound_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_hackathon_musichackday2018_play_sound_logs_on_user_id  (user_id)
#  musichackday2018_sound_resource_log_index                    (sound_type,sound_id)
#

class Hackathon::Musichackday2018::PlaySoundLog < ApplicationRecord
  belongs_to :sound, polymorphic: true

  enum state: {
    standby: 0,
    download: 1,
    playing: 2,
    complete: 3
  }

  def download_and_upload_file!
    self.sound.download_and_upload_file!
    self.download!
  end

  def next_sound
    
  end
end
