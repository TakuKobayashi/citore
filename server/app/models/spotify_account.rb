# == Schema Information
#
# Table name: accounts
#
#  id           :integer          not null, primary key
#  user_type    :string(255)      not null
#  user_id      :integer          not null
#  type         :string(255)
#  uid          :string(255)      not null
#  token        :text(65535)
#  token_secret :text(65535)
#  expired_at   :datetime
#  options      :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_accounts_on_uid           (uid)
#  unique_homepage_accounts_index  (user_type,user_id,type) UNIQUE
#

class SpotifyAccount < Account
  has_many :playlists, class_name: 'SpotifyPlaylist', foreign_key: :account_id

  def get_playlists
    return ApplicationRecord.request_and_parse_json(url: "https://api.spotify.com/v1/me/playlists", headers: {Authorization: "Bearer #{self.token}"})
  end

  # artist, playlist, track.
  def searches(text:, search_type: :track)
    #method: :get, params: {}, headers: {}
    return ApplicationRecord.request_and_parse_json(url: "https://api.spotify.com/v1/search", params: {q: text, type: search_type, limit: 50}, headers: {Authorization: "Bearer #{self.token}"})
  end

  def playlist_tracks
    playlist = get_playlists
    tracks_hashes = []
    playlist["items"].each do |playlist_item|
      tracks_hashes << ApplicationRecord.request_and_parse_json(url: playlist_item["tracks"]["href"], headers: {Authorization: "Bearer #{self.token}"})
    end
    return tracks_hashes
  end

  #max 50件
  def tracks(ids: [])
    return ApplicationRecord.request_and_parse_json(url: "https://api.spotify.com/v1/tracks", params: {ids: ids.join(",")}, headers: {Authorization: "Bearer #{self.token}"})
  end

  def recommendations
    return ApplicationRecord.request_and_parse_json(url: "https://developer.spotify.com/web-api/get-recommendations/", headers: {Authorization: "Bearer #{self.token}"})
  end

  def audio_analysis(track_id:)
    return ApplicationRecord.request_and_parse_json(url: "https://api.spotify.com/v1/audio-analysis/#{track_id}", headers: {Authorization: "Bearer #{self.token}"})
  end

  def audio_features(track_id:)
    return ApplicationRecord.request_and_parse_json(url: "https://api.spotify.com/v1/audio-features/#{track_id}", headers: {Authorization: "Bearer #{self.token}"})
  end
end
