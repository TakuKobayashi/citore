# == Schema Information
#
# Table name: moi_voice_twitcas_users
#
#  id              :integer          not null, primary key
#  twitcas_user_id :string(255)      not null
#  name            :string(255)
#  access_token    :text(65535)
#  expires_in      :integer          default(0), not null
#  last_logined_at :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_moi_voice_twitcas_users_on_twitcas_user_id  (twitcas_user_id) UNIQUE
#

class MoiVoice::TwitcasUser < ApplicationRecord
  has_many :live_straems, class_name: 'MoiVoice::LiveStream', foreign_key: :moi_voice_twitcas_user_id
  has_many :comments, class_name: 'MoiVoice::LiveStreamComment', foreign_key: :moi_voice_twitcas_user_id

  TWITCAS_API_URL_ROOT = "https://apiv2.twitcasting.tv"

  def self.get_oauth_url
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    return TWITCAS_API_URL_ROOT + "/oauth2/authorize?client_id=" + apiconfig["twitcas"]["client_id"] + "&response_type=code"
  end

  def self.oauth!(code, redirect_url)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    http_client = HTTPClient.new
    request_params = apiconfig["twitcas"].merge({
      "code" => code,
      "grant_type" => "authorization_code",
      "redirect_uri" => redirect_url
    })
    response_oauth = http_client.post(TWITCAS_API_URL_ROOT + "/oauth2/access_token", request_params, {'Content-Type' => 'application/json;charset=UTF-8'})
    hash = JSON.parse(response_oauth.body)
    request_user_header = {
      'Content-Type' => 'application/json;charset=UTF-8',
      'Authorization' => 'Bearer ' + hash["access_token"]
    }
    response_user = http_client.get(TWITCAS_API_URL_ROOT + "/verify_credentials", {}, request_user_header)
    user_hash = JSON.parse(response_user.body)
    user = MoiVoice::TwitcasUser.find_or_initialize_by(twitcas_user_id: user_hash["user"]["id"])
    user.update!(access_token: user_hash["access_token"], name: user_hash["user"]["name"], last_logined_at: Time.now, expires_in: hash["expires_in"])
    return user
  end
end
