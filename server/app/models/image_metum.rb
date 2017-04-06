# == Schema Information
#
# Table name: image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)      not null
#  title             :string(255)      not null
#  original_filename :string(255)
#  filename          :string(255)
#  url               :string(255)
#  from_site_url     :string(255)
#
# Indexes
#
#  index_image_meta_on_from_site_url_and_url           (from_site_url,url) UNIQUE
#  index_image_meta_on_original_filename_and_filename  (original_filename,filename) UNIQUE
#  index_image_meta_on_title                           (title)
#

class ImageMetum < ApplicationRecord
  IMAGE_FILE_EXTENSIONS = [
    ".agp",
    ".ai", #Illustrator
    ".cdr",
    ".cpc", ".cpi",
    ".eps",
    ".eri",
    ".gif", #GIF
    ".iff", ".ilbm", ".lbm",
    ".ima",
    ".jpg", ".jpeg", #JPEG
    ".jxr", ".hdp", ".wdp",
    ".jp2", ".j2c",
    ".mki",
    ".mag",
    ".pi",
    ".pict", ".pic", ".pct",
    ".pdf", #PDF
    ".png", #PNG
    ".psd", ".psb", ".pdd", #PSD
    ".psp",
    ".svg", #SVG
    ".tga", ".tpic", #TGA 3Dモデルのテクスチャーとかによく使われる
    ".tif", #tif 文字とかフォントとか
    ".webp",
    ".bmp", #BMP
  ]

  def match_image_filename(filepath)
    paths = filepath.split("/")
    imagefile_name = paths.detect{|p| IMAGE_FILE_EXTENSIONS.any?{|ie| p.include?(ie)} }
    return "" if imagefile_name.blank?
    ext = IMAGE_FILE_EXTENSIONS.detect{|ie| imagefile_name.include?(ie) }
    return imagefile_name.match(/(.+?#{ext})/).to_s
  end

  def s3_file_image_root
    return ""
  end

  def s3_file_url
    return "https://taptappun.s3.amazonaws.com/" + self.s3_file_image_root + self.filename
  end

  def file_url
    if self.filename.present?
      return self.s3_file_url
    else
      return self.url
    end
  end

  def save_to_s3!
    if filename.present?
      return false
    end
    aurl = Addressable::URI.parse(URI.unescape(self.url))
    http_client = HTTPClient.new
    response = http_client.get_content(aurl.to_s, {}, {})

    self.original_filename = self.match_image_filename(aurl.to_s)
    self.filename = SecureRandom.hex + File.extname(self.original_filename)
    s3 = Aws::S3::Client.new
    filepath = self.s3_file_image_root + self.filename
    s3.put_object(bucket: "taptappun",body: response, key: filepath, acl: "public-read")
    save!
  end

  def convert_to_base64
    filepath = self.s3_file_image_root + self.filename
    ext = File.extname(self.filename)
    s3 = Aws::S3::Client.new
    binary = s3.get_object(bucket: "taptappun",key: filepath)
    base64_image = Base64.strict_encode64(binary.body.read)
    return "data:image/" + ext[1..ext.size] + ";base64," + base64_image
  end
end
