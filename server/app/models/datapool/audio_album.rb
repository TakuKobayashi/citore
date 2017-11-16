# == Schema Information
#
# Table name: datapool_audio_albums
#
#  id        :integer          not null, primary key
#  type      :string(255)
#  title     :string(255)      default(""), not null
#  album_id  :string(255)      not null
#  image_url :string(255)
#  url       :string(255)
#  track_ids :text(65535)
#  options   :text(65535)
#
# Indexes
#
#  index_datapool_audio_albums_on_album_id_and_type  (album_id,type) UNIQUE
#

class Datapool::AudioAlbum < ApplicationRecord
end
