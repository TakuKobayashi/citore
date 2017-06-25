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
#
# Indexes
#
#  fka_inquiry_image_id_url_index  (inquiry_tweet_id,image_url)
#

class FeyKunAi::InquiryTweetImage < TwitterRecord
  serialize :exifs, JSON
  serialize :output, JSON

  belongs_to :tweet, class_name: 'FeyKunAi::InquiryTweet', foreign_key: :inquiry_tweet_id, required: false

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

  def s3_file_url
    return "https://taptappun.s3.amazonaws.com/" + IMAGE_S3_FILE_ROOT + self.out_put.object_image_name
  end
end
