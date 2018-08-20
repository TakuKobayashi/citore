# == Schema Information
#
# Table name: datapool_audio_meta
#
#  id                :bigint(8)        not null, primary key
#  type              :string(255)
#  file_genre        :integer          default("audio_file"), not null
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  other_src         :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_audio_meta_on_origin_src  (origin_src)
#  index_datapool_audio_meta_on_title       (title)
#

class Datapool::NiconicoAudioMetum < Datapool::AudioMetum
  def download_resource
    super.download_resource
#    aurl = Addressable::URI.parse(self.src)
#    doc = RequestParser.request_and_parse_html(url: aurl.to_s, header: {"User-Agent" => "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Mobile Safari/537.36"}, options: {:follow_redirect => true})
#    doc.css("#jsDataContainer")
#    file_name = self.original_filename + ".mp4"
#    output_file_path = Rails.root.to_s + "/tmp/video/" + file_name
#    system("youtube-dl " + self.src + " -o " + output_file_path.to_s)
#    file = File.open(output_file_path)
#    blob = file.read
#    File.delete(output_file_path)
#    return blob
  end
end
