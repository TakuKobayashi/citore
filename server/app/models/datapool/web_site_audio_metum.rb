# == Schema Information
#
# Table name: datapool_audio_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  file_genre        :integer          default("audio_file"), not null
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  query             :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_audio_meta_on_origin_src  (origin_src)
#  index_datapool_audio_meta_on_title       (title)
#

class Datapool::WebSiteAudioMetum < Datapool::AudioMetum
  # audioタグがそんなにあるわけではないので、そのサイトにある音声ファイル全てを抑えにいく勢い
  def self.suppress!(url:)
    address_url = Addressable::URI.parse(url.to_s)
    doc = ApplicationRecord.request_and_parse_html(address_url.to_s, request_method)
    return []
  end
end