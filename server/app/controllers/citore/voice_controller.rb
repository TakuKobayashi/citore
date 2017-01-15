class Citore::VoiceController < BaseController
  def download
    erotic_word = Citore::EroticWord.find_by_used_cache(id: params[:word_id].to_i)
    voice = erotic_word.voices.find_by(speaker_name: params[:speaker_name])
    if voice.present?
      s3 = Aws::S3::Client.new
      origin_filename = File.basename(voice.file_name)
      ext = File.extname(origin_filename)
      resp = s3.get_object({bucket: "taptappun", key: voice.file_name})
      send_data(resp.body.read,{filename: origin_filename, type: "audio/" + ext[1..(ext.size - 1)]})
    else
      head(:ok)
    end
  end
end
