# == Schema Information
#
# Table name: voices
#
#  id               :integer          not null, primary key
#  seed_type        :string(255)      not null
#  seed_id          :integer          not null
#  speacker_keyword :string(255)      not null
#  speech_file_name :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_voices_on_seed_type_and_seed_id_and_speacker_keyword  (seed_type,seed_id,speacker_keyword) UNIQUE
#

class Voice < ApplicationRecord

  VOICE_FILE_ROOT = "/tmp/voices/"

  def self.voice_file_root_path
    return Rails.root.to_s + VOICE_FILE_ROOT
  end
end
