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
#  index_accounts_on_uid                      (uid)
#  unique_user_and_id_and_uid_accounts_index  (user_type,user_id,type,uid) UNIQUE
#

class SpotifyAccount < Account
  has_many :playlists, class_name: 'SpotifyPlaylist', foreign_key: :account_id

  def self.sign_up!(user: ,omni_auth:)
    account = self.find_or_initialize_by(user: user, uid: omni_auth.uid)
    account.token = omni_auth.credentials.token
    account.expired_at = Time.at(omni_auth.credentials.expires_at)
    account.options = {extra: omni_auth.extra.to_hash}
    account.save!
  end

  def import_and_load_playlists!
    import_playlists = []
    playlist_hashes = get_playlists
    playlist_ids = self.playlists.where(playlist_id: playlists["items"].map{|pl| pl["id"]}).pluck(:playlist_id)

    playlist_hashes["items"].each do |item|
      next if playlist_ids.include?(item["id"])
      import_playlists << self.playlists.new(
        playlist_id: item["id"],
        name: item["name"],
        pulishing: item["public"],
        url: item["external_urls"]["spotify"],
        image_url: item["images"].max_by{|image| image["height"].to_i * image["width"].to_i }["url"]
      )
    end
    if import_playlists.present?
      SpotifyPlaylist.import!(import_playlists)
    end

    playlist_id_track_ids = {}
    import_tracks = []
    playlist_hashes["items"].each do |item|
      playlist_id_tracks[item["id"]] = []
      track_jsons = RequestParser.request_and_parse_json(url: item["tracks"]["href"], header: {Authorization: "Bearer #{self.token}"})
      track_jsons["items"].each do |t_json|
        playlist_id_tracks[item["id"]] << Datapool::SpotifyAudioTrack.new(
          title: t_json["name"],
          track_id: t_json["id"],
          isrc: t_json["external_ids"]["isrc"],
          duration: t_json["duration_ms"].to_f / 1000,
          url: t_json["external_urls"]["spotify"]
        )
      end
    end
    import_tracks = playlist_id_tracks.values.flatten.select{|t| t.new_crecord?}
    if import_tracks.present?
      Datapool::SpotifyAudioTrack.import!(import_tracks)
    end

    spotify_playlists = self.playlists.where(playlist_id: playlists["items"].map{|pl| pl["id"]})
    return spotify_playlists
  end

  def get_playlists(offset: 0)
    return RequestParser.request_and_parse_json(url: "https://api.spotify.com/v1/me/playlists", params: {limit: 50, offset: offset}, header: {Authorization: "Bearer #{self.token}"})
  end

  # artist, playlist, track.
  def searches(text:, search_type: :track)
    #method: :get, params: {}, header: {}
    return RequestParser.request_and_parse_json(url: "https://api.spotify.com/v1/search", params: {q: text, type: search_type, limit: 50}, header: {Authorization: "Bearer #{self.token}"})
  end

  def playlist_tracks
    playlist = get_playlists
    tracks_hashes = []
    playlist["items"].each do |playlist_item|
      tracks_hashes << RequestParser.request_and_parse_json(url: playlist_item["tracks"]["href"], header: {Authorization: "Bearer #{self.token}"})
    end
    return tracks_hashes
  end

  #max 50件
  def tracks(ids: [])
    return RequestParser.request_and_parse_json(url: "https://api.spotify.com/v1/tracks", params: {ids: ids.join(",")}, header: {Authorization: "Bearer #{self.token}"})
  end

  def recommendations
    return RequestParser.request_and_parse_json(url: "https://developer.spotify.com/web-api/get-recommendations/", header: {Authorization: "Bearer #{self.token}"})
  end

  def audio_analysis(track_id:)
    return RequestParser.request_and_parse_json(url: "https://api.spotify.com/v1/audio-analysis/#{track_id}", header: {Authorization: "Bearer #{self.token}"})
  end

  def audio_features(track_id:)
    return RequestParser.request_and_parse_json(url: "https://api.spotify.com/v1/audio-features/#{track_id}", header: {Authorization: "Bearer #{self.token}"})
  end
end
