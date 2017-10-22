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

class Datapool::AudioMetum < Datapool::ResourceMetum
  enum file_genre: {
    audio_file: 0,
    video_file: 1,
    audio_streaming: 2,
    video_streaming: 3
  }

  AUDIO_FILE_EXTENSIONS = [
    #https://ja.wikipedia.org/wiki/AIFF
    ".aiff",".aif", ".aifc", ".afc",
    ".mp3",
    ".wav",
    #https://ja.wikipedia.org/wiki/Vorbis
    ".ogg", ".oga",
    #https://ja.wikipedia.org/wiki/Opus_(%E9%9F%B3%E5%A3%B0%E5%9C%A7%E7%B8%AE)
    ".opus",
    #https://ja.wikipedia.org/wiki/AAC
    ".mov",".mp4","m2ts",".m4a",".m4b",".m4p",".3gp",".3g2",".aac",
    #https://ja.wikipedia.org/wiki/Windows_Media_Audio
    ".wma", ".asf",
    #https://ja.wikipedia.org/wiki/ATRAC
    ".omg", ".oma", ".aa3",
    ".mp4",
    #https://ja.wikipedia.org/wiki/FLAC
    ".flac", ".fla",
    ".mpc",
    ".ape", ".mac",
    #https://ja.wikipedia.org/wiki/TTA
    ".tta", ".mka", ".mkv",
    #https://ja.wikipedia.org/wiki/WavPack
    ".wv",
    #https://ja.wikipedia.org/wiki/La_(%E9%9F%B3%E5%A3%B0%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%83%E3%83%88)
    ".la",
    #https://ja.wikipedia.org/wiki/Apple_Lossless
    ".alac"
  ]

  def save_filename
    if self.original_filename.present?
      return self.original_filename
    end
    return super
  end

  def self.audiofile?(filename)
    return AUDIO_FILE_EXTENSIONS.include?(File.extname(filename))
  end
end
