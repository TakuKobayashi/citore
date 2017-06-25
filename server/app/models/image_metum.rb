# == Schema Information
#
# Table name: image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  filename          :string(255)
#  src               :string(255)
#  from_site_url     :string(255)
#  checksum          :string(255)
#
# Indexes
#
#  index_image_meta_on_checksum                        (checksum)
#  index_image_meta_on_from_site_url_and_src           (from_site_url,src) UNIQUE
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

  def self.match_image_filename(filepath)
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
      return self.src
    end
  end

  def save_filename
    if original_filename.present?
      return original_filename
    end
    return SecureRandom.hex
  end

  def self.crawl_images!(url:, start_page: 1, end_page: 1, filter: nil, request_method: :get)
    images = []
    (start_page.to_i..end_page.to_i).each do |page|
      address_url = Addressable::URI.parse(url % page.to_s)
      doc = ApplicationRecord.request_and_parse_html(address_url.to_s, request_method)
      images += self.generate_objects_from_parsed_html(doc: doc, filter: filter, from_site_url: address_url.to_s)
    end
    self.import!(images, on_duplicate_key_update: [:title])
    return images
  end

  def self.generate_objects_from_parsed_html(doc:, filter: nil, from_site_url: nil)
    images = []
    if filter.present?
      doc = doc.css(filter)
    end
    doc.css("img").each do |d|
      title = d[:alt]
      if title.blank?
        title = d[:title]
      end
      if title.blank?
        title = d[:name]
      end
      if title.blank?
        title = d.text
      end
      image_url = Addressable::URI.parse(d[:src])
      from_url = Addressable::URI.parse(from_site_url.to_s)
      if image_url.scheme.blank?
        image_url.scheme = from_url.scheme.to_s
      end
      if image_url.host.blank?
        image_url.host = from_url.host
      end
      next if image_url.scheme.blank? && image_url.host.blank? && image_url.to_s.size > 256
      images << self.new(src: image_url.to_s, title: title.to_s, original_filename: self.match_image_filename(image_url.to_s), from_site_url: from_site_url)
    end
    return images
  end

  def download_image
    aurl = Addressable::URI.parse(URI.unescape(self.src))
    client = HTTPClient.new
    response = client.get(aurl.to_s)
    return response
  end

  def can_download?
    aurl = Addressable::URI.parse(URI.unescape(self.src))
    return aurl.scheme.present? && aurl.host.present?
  end

  def save_to_s3!
    if filename.present?
      return false
    end
    aurl = Addressable::URI.parse(URI.unescape(self.src))
    uri = URI.parse(aurl.to_s)
    self.original_filename = self.class.match_image_filename(aurl.to_s)
    self.filename = SecureRandom.hex + File.extname(self.original_filename)
    s3 = Aws::S3::Client.new
    filepath = self.s3_file_image_root + self.filename
    s3.put_object(bucket: "taptappun",body: uri.open.read, key: filepath, acl: "public-read")
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
