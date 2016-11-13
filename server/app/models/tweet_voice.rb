# == Schema Information
#
# Table name: tweet_voices
#
#  id               :integer          not null, primary key
#  tweet_seed_id    :integer          not null
#  speacker_keyword :string(255)      not null
#  speech_file_path :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_tweet_voices_on_tweet_seed_id_and_speacker_keyword  (tweet_seed_id,speacker_keyword)
#

class TweetVoice < ApplicationRecord
  belongs_to :tweet_seed

  VOICE_FILE_ROOT = "/tmp/voices/"

  def self.voice_file_root_path
    return Rails.root.to_s + VOICE_FILE_ROOT
  end
end
