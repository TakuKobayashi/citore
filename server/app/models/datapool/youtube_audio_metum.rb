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
  has_one :audio_track, class_name: 'Datapool::YoutubeAudioTrack', foreign_key: :audio_metum_id

  def self.search_and_import!(keyword:)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = apiconfig["google_api"]["key"]
    youtube_search = youtube.list_searches("id,snippet", max_results: 50,  type: "video", q: keyword.to_s)
    audio_meta = []
    id_tracks = Datapool::YoutubeAudioTrack.where(track_id: youtube_search.items.map{|item| item.id.video_id.to_s}).preload(:metum).index_by(&:track_id)
    self.transaction do
      youtube_search.items.each do |item|
        if id_tracks[item.id.video_id.to_s].present?
          audio_meta << id_tracks[item.id.video_id.to_s].metum
          next
        end
        metum = Datapool::YoutubeAudioMetum.constract(
          url: "https://www.youtube.com/watch?v=" + item.id.video_id.to_s,
          title: ApplicationRecord.basic_sanitize(item.snippet.title),
          file_genre: :video_streaming,
          options: {
            channel_title: item.snippet.channel_title,
            thumbnail_image_url: item.snippet.thumbnails.default.url
          }
        )
        metum.save!
        Datapool::YoutubeAudioTrack.create(
          audio_metum_id: metum.id,
          title: metum.title,
          track_id: item.id.video_id.to_s,
          url: metum.src,
          options: {
            channel_title: item.snippet.channel_title,
            thumbnail_image_url: item.snippet.thumbnails.default.url
          }
        )
        audio_meta << metum
      end
    end
    return audio_meta
  end

  def download_and_upload_file!
    file_name = SecureRandom.hex + ".m4a"
    output_file_path = Rails.root.to_s + "/tmp/audio/" + file_name
    system("youtube-dl " + self.src + " -x -o " + output_file_path.to_s + " --audio-format=m4a")
    fileurl = Datapool::YoutubeAudioMetum.upload_s3(File.open(output_file_path), file_name)
    self.options["upload_audio_file_url"] = ApplicationRecord::S3_ROOT_URL + fileurl
    File.delete(output_file_path)
    self.save!
  end

  def artist_name
    self.options["channel_title"].to_s
  end

  def thumbnail_image_url
    self.options["thumbnail_image_url"].to_s
  end

  def file_url
    self.options["upload_audio_file_url"].to_s
  end
end
