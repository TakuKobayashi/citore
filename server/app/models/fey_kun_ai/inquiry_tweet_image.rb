# == Schema Information
#
# Table name: fey_kun_ai_inquiry_tweet_images
#
#  id               :integer          not null, primary key
#  inquiry_tweet_id :string(255)      not null
#  image_url        :string(255)      not null
#  exifs            :text(65535)
#  checksum         :string(255)      not null
#  output           :text(65535)
#  state            :integer          default("standby"), not null
#
# Indexes
#
#  fka_inquiry_image_id_url_index  (inquiry_tweet_id,image_url)
#

class FeyKunAi::InquiryTweetImage < TwitterRecord
  enum state: [:standby, :analizing, :complete]
  serialize :exifs, JSON
  serialize :output, JSON

  belongs_to :tweet, class_name: 'FeyKunAi::InquiryTweet', foreign_key: :inquiry_tweet_id, required: false

  def request_analize!
    client = HTTPClient.new
    client.connect_timeout = 600
    client.send_timeout    = 600
    client.receive_timeout = 600

    client.set_auth("http://52.191.168.217:80", "mehdi", "test")
    self.analizing!
    response = client.post("http://52.191.168.217:80/request_analysis/api", {"image_id" => self.id.to_s, "image_url" => self.image_url.to_s}.to_json, {"Content-Type" => "application/json"})
    self.complete!
  end

  def tweet_text
    return "Fake Rate:" + self.output["error_ratio"].to_s + " " + self.output["caption"].to_s + "\n"
  end

  def set_image_meta_data
    file_ext = File.extname(self.image_url).downcase
    aurl = Addressable::URI.parse(URI.unescape(self.image_url))
    uri = URI.parse(aurl.to_s)
    filepath = Rails.root.to_s + "/tmp/" + SecureRandom.hex + file_ext
    File.open(filepath, 'wb'){|f| f.write(uri.open.read) }
    if file_ext == ".jpg" || file_ext == ".jpeg"
      data = EXIFR::JPEG.new(filepath)
      self.exifs = data.to_hash
    elsif file_ext == ".tif" || file_ext == ".tiff"
      data = EXIFR::TIFF.new(filepath)
      self.exifs = data.to_hash
    else
      data = FastImage.new(filepath)
      self.exifs = {width: data.size[0], height: data.size[1], comment: nil}
    end
    self.checksum = Digest::MD5.file(filepath)
    File.delete(filepath)
  end

  IMAGE_S3_FILE_ROOT = "project/fey_kun/images/"

  def self.upload_s3(file)
    s3 = Aws::S3::Client.new
    filename = SecureRandom.hex + ".png"
    filepath = IMAGE_S3_FILE_ROOT + filename
    s3.put_object(bucket: "taptappun",body: file.read, key: filepath, acl: "public-read")
    return filename
  end

  def s3_object_file_url
    return "https://taptappun.s3.amazonaws.com/" + IMAGE_S3_FILE_ROOT + self.output["object_image_name"]
  end

  def s3_error_file_url
    return "https://taptappun.s3.amazonaws.com/" + IMAGE_S3_FILE_ROOT + self.output["err_image_name"]
  end
end
