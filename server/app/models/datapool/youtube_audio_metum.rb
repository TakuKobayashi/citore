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

require 'google/apis/youtube_v3'

class Datapool::YoutubeAudioMetum < Datapool::AudioMetum
  has_one :audio_track, class_name: 'Datapool::YoutbeAudioTrack', foreign_key: :audio_metum_id

  def self.search_and_import!(keyword:)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = apiconfig["google_api"]["key"]
    youtube_search = youtube.list_searches("id,snippet", max_results: 50,  type: "video", q: keyword.to_s)
    audio_meta = []
    self.transaction do
      audio_meta = youtube_search.items.map do |item|
        metum = Datapool::YoutubeAudioMetum.constract(
          url: "https://www.youtube.com/watch?v=" + item.id.video_id.to_s,
          title: item.snippet.title,
          file_genre: :video_streaming,
          options: {
            channel_title: item.snippet.channel_title,
            thumnail_image_url: item.snippet.thumbnails.default.url
        })
        metum.save!
        metum
      end
    end
    return audio_meta
  end
end
