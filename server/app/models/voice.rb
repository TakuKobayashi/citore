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
  VOICE_S3_FILE_ROOT = "project/citore/voices/"

  def self.voice_file_root_path
    return Rails.root.to_s + VOICE_FILE_ROOT
  end

  def self.generate_and_upload_voice(text, recource_type, speaker_name, option = {})
  	apiconfig = YAML.load(File.open("config/apiconfig.yml"))
    http_client = HTTPClient.new
    params = TweetSeed::VOICE_PARAMS.merge({
      username: apiconfig["aitalk"]["username"],
      password: apiconfig["aitalk"]["password"],
      text: text,
      speaker_name: speaker_name
    }).merge(option)
    response = http_client.get_content("http://webapi.aitalk.jp/webapi/v2/ttsget.php", params, {})
    file_name = "#{speaker_name}_" + SecureRandom.hex + ".wav"

    s3 = Aws::S3::Client.new
    file_path = VOICE_S3_FILE_ROOT + file_name
    s3.put_object(bucket: "taptappun",body: response,key: file_path)
    voice = VoiceDynamo.find(word: text, speaker_name: speaker_name)
    if voice.blank?
      voice = VoiceDynamo.new
    end
    voice.word = text
    voice.speaker_name = speaker_name
    voice.info = {file_path: file_path, recource_type: recource_type}
    voice.save!
  end

  def self.all_speacker_names
    girl_speackers = ["nozomi", "sumire", "maki", "kaho", "akari", "nanako", "reina", "anzu", "chihiro", "miyabi_west", "aoi", "akane_west"]
    boy_speackers = ["seiji", "hiroshi", "osamu", "taichi", "koutarou", "yuuto", "yamato_west"]
    emo_girl_speackers = ["nozomi_emo", "maki_emo", "reina_emo"]
    emo_boy_speackers = ["taichi_emo"]
    speackers = girl_speackers + boy_speackers + emo_girl_speackers + emo_boy_speackers
    return speackers
  end
end
