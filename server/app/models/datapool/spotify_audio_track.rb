# == Schema Information
#
# Table name: datapool_audio_tracks
#
#  id        :integer          not null, primary key
#  type      :string(255)
#  title     :string(255)      not null
#  track_id  :string(255)      not null
#  isrc      :string(255)
#  duration  :integer          default(0), not null
#  url       :string(255)
#  album_ids :text(65535)
#  options   :text(65535)
#
# Indexes
#
#  index_datapool_audio_tracks_on_isrc               (isrc)
#  index_datapool_audio_tracks_on_track_id_and_type  (track_id,type) UNIQUE
#

class Datapool::SpotifyAudioTrack < Datapool::AudioTrack
end