# == Schema Information
#
# Table name: datapool_image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  query             :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_image_meta_on_origin_src  (origin_src)
#  index_datapool_image_meta_on_title       (title)
#

class Datapool::ImageMetum < ApplicationRecord
  serialize :options, JSON

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

  CRAWL_IMAGE_ROOT_PATH = "project/crawler/images/"

  def src
    url = Addressable::URI.parse(self.origin_src)
    url.query = self.query
    return url.to_s
  end

  def src=(url)
    aurl = Addressable::URI.parse(url)
    pure_url = aurl.origin.to_s + aurl.path.to_s
    if pure_url.size > 255
      word_counter = 0
      srces, other_pathes = pure_url.split("/").partition do |word|
        word_counter = word_counter + word.size + 1
        word_counter <= 255
      end
      self.origin_src = srces.join("/")
      self.query = other_pathes.join("/") + aurl.query.to_s
    else
      self.origin_src = pure_url
      self.query = aurl.query
    end
  end

  def self.match_image_filename(filepath)
    paths = filepath.split("/")
    imagefile_name = paths.detect{|p| IMAGE_FILE_EXTENSIONS.any?{|ie| p.include?(ie)} }
    return "" if imagefile_name.blank?
    ext = IMAGE_FILE_EXTENSIONS.detect{|ie| imagefile_name.include?(ie) }
    return imagefile_name.match(/(.+?#{ext})/).to_s
  end

  def self.s3_file_image_root
    return CRAWL_IMAGE_ROOT_PATH
  end

  def save_filename
    if self.original_filename.present?
      return self.original_filename
    end
    return SecureRandom.hex
  end

  def download_image_response
    aurl = Addressable::URI.parse(self.src)
    client = HTTPClient.new
    response = client.get(aurl.to_s)
    return response
  end

  def self.upload_s3(binary, filename)
    s3 = Aws::S3::Client.new
    filepath = self.s3_file_image_root + filename
    s3.put_object(bucket: "taptappun",body: binary, key: filepath, acl: "public-read")
    return filepath
  end

  def convert_to_base64
    filepath = self.src
    ext = File.extname(filepath)
    s3 = Aws::S3::Client.new
    binary = s3.get_object(bucket: "taptappun",key: filepath)
    base64_image = Base64.strict_encode64(binary.body.read)
    return "data:image/" + ext[1..ext.size] + ";base64," + base64_image
  end

  def self.constract(image_url:, title:, check_image_file: false, options: {})
    aimage_url = Addressable::URI.parse(image_url.to_s)
    image_type = nil
    if check_image_file
      # 画像じゃないものも含まれていることもあるので分別する
      image_type = FastImage.type(aimage_url.to_s)
      if image_type.blank?
        Rails.logger.warn("it is not image:" + aimage_url.to_s)
        return nil
      end
    end
    image = self.new(title: title.to_s, options: options)
    if aimage_url.scheme == "data"
      image_binary =  Base64.decode64(aimage_url.to_s.gsub(/data:image\/.+;base64\,/, ""))
      new_filename = SecureRandom.hex + ".#{image_type.to_s.downcase}"
      uploaded_path = self.upload_s3(image_binary, new_filename)
      image.src = ApplicationRecord::S3_ROOT_URL + uploaded_path
    else
      image.src = aimage_url.to_s
    end
    filename = self.match_image_filename(image.src.to_s)
    if filename.size > 255
      image.original_filename = SecureRandom.hex + File.extname(filename)
    else
      image.original_filename = filename
    end
    return image
  end

  def self.calc_resize_text(width:, height:, max_length:)
    if width > height
      resized_width = [width, max_length].min
      resized_height = ((resized_width.to_f / width.to_f) * height.to_f).to_i
      return "#{resized_width.to_i}x#{resized_height.to_i}"
    else
      resized_height = [height, max_length].min
      resized_width = ((resized_height.to_f / height.to_f) * width.to_f).to_i
      return "#{resized_width.to_i}x#{resized_height.to_i}"
    end
  end

  def self.compress_to_zip(zip_filepath:, images: [])
    filename_hash = {}
    Zip::OutputStream.open(zip_filepath) do |stream|
      images.each do |image|
        response = image.download_image_response
        next if (response.status >= 300 && response.status != 304) || !response.headers["Content-Type"].to_s.include?("image")
        if filename_hash[image.save_filename].nil?
          stream.put_next_entry(image.save_filename)
        else
          stream.put_next_entry(SecureRandom.hex + File.extname(image.save_filename))
        end
        stream.print(response.body)
        filename_hash[image.save_filename] = image
      end
    end
    return zip_filepath
  end
end
