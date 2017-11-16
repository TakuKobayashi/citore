# == Schema Information
#
# Table name: spotify_playlists
#
#  id          :integer          not null, primary key
#  account_id  :integer          not null
#  playlist_id :string(255)      not null
#  name        :string(255)
#  image_url   :string(255)
#  url         :string(255)
#  pulishing   :boolean          default(FALSE), not null
#  options     :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_spotify_playlists_on_account_id   (account_id)
#  index_spotify_playlists_on_playlist_id  (playlist_id)
#

class SpotifyPlaylist < ApplicationRecord
  has_many :track_resources, as: :resource, class_name: 'Datapool::TrackResource'
  has_many :tracks, through: :track_resources, source: :track
end
