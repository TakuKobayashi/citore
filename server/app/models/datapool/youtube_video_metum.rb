# == Schema Information
#
# Table name: datapool_video_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  front_image_url   :text(65535)
#  data_category     :integer          default("file"), not null
#  bitrate           :integer          default(0), not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  other_src         :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_video_meta_on_origin_src  (origin_src)
#  index_datapool_video_meta_on_title       (title)
#

class Datapool::YoutubeVideoMetum < Datapool::VideoMetum
  YOUTUBE_HOSTS = [
    "www.youtube.com",
    "youtu.be"
  ]

  def download_resource
    aurl = Addressable::URI.parse(self.src)
    file_name = self.original_filename + ".mp4"
    output_file_path = Rails.root.to_s + "/tmp/video/" + file_name
    system("youtube-dl " + self.src + " -o " + output_file_path.to_s)
    file = File.open(output_file_path)
    blob = file.read
    File.delete(output_file_path)
    return blob
  end

  def self.youtube?(url)
    aurl = Addressable::URI.parse(url.to_s)
    return (YOUTUBE_HOSTS.any?{|host| host.include?(aurl.host)} && aurl.path.include?("/watch"))
  end
end
