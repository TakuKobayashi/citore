# == Schema Information
#
# Table name: voice_words
#
#  id           :integer          not null, primary key
#  from_type    :string(255)      not null
#  from_id      :integer          not null
#  speaker_name :string(255)      not null
#  file_name    :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  vioce_from_indexes  (from_type,from_id,speaker_name) UNIQUE
#

class VoiceWord < ApplicationRecord
  belongs_to :from, polymorphic: true

  VOICE_PARAMS = {
    ext: "wav",
    volume: 2.0,
    speed: 0.6,
    range: 2.0,
    pitch: 1.8,
    style: {"j" => "1.0"}
  }

  SUGARCOAT_VOICE_PARAMS = {
    ext: "aac",
    volume: 2.0,
    speed: 1.0,
    range: 1.0,
    pitch: 1.0,
    style: {"j" => "1.0"}
  }

  VOICE_FILE_ROOT = "/tmp/voices/"
  VOICE_S3_FILE_ROOT = "project/citore/voices/"
  VOICE_S3_SUGARCOAT_FILE_ROOT = "project/sugarcoat/voices/"

  def s3_file_url
    return "https://taptappun.s3.amazonaws.com/" + VoiceWord::VOICE_S3_FILE_ROOT + self.file_name
  end

  def self.voice_file_root_path
    return Rails.root.to_s + VOICE_FILE_ROOT
  end

  def self.generate_and_upload_voice!(from_clazz, text, speaker_name, upload_file_path = VOICE_S3_FILE_ROOT, acl = :private, options = {})
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    params = VOICE_PARAMS.merge({
      username: apiconfig["aitalk"]["username"],
      password: apiconfig["aitalk"]["password"],
      text: text,
      speaker_name: speaker_name
    }).merge(options)
    file_name = "#{speaker_name}_" + SecureRandom.hex + "." + params[:ext]

    voice = VoiceWord.find_by(from: from_clazz, speaker_name: speaker_name)
    if voice.present?
      return voice
    end

    http_client = HTTPClient.new
    response = http_client.get_content("http://webapi.aitalk.jp/webapi/v2/ttsget.php", params, {})
    
    s3 = Aws::S3::Client.new
    file_path = upload_file_path + file_name
    s3.put_object(bucket: "taptappun",body: response,key: file_path, :acl => acl)

    voice = VoiceWord.create!(from: from_clazz, speaker_name: speaker_name, file_name: file_path)
    return voice
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
