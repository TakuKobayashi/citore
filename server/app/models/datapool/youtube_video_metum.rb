# == Schema Information
#
# Table name: datapool_video_meta
#
#  id              :bigint(8)        not null, primary key
#  type            :string(255)
#  title           :string(255)      not null
#  front_image_url :text(65535)
#  data_category   :integer          default("file"), not null
#  bitrate         :integer          default(0), not null
#  origin_src      :string(255)      not null
#  other_src       :text(65535)
#  options         :text(65535)
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

  def src=(url)
    aurl = Addressable::URI.parse(url)
    query_hash = aurl.query_values
    self.origin_src = aurl.origin.to_s + aurl.path.to_s + "?v=" + query_hash["v"].to_s
    query_hash.delete_if{|key, value| key == "v" }
    if query_hash.present?
      self.other_src = "&" + query_hash.map{|key, value| key.to_s + "=" + value.to_s }.join("&")
    else
      self.other_src = ""
    end
  end

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
