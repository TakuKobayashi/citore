class Datapool::ResourceMetum < ApplicationRecord
  self.abstract_class = true

  S3_ROOT_URL = "https://taptappun.s3.amazonaws.com/"

  def src
    url = Addressable::URI.parse(self.origin_src)
    url.query = self.query
    return url.to_s
  end

  def src=(url)
    origin_src, query = Datapool::ResourceMetum.url_partition(url: url)
    self.origin_src = origin_src
    self.query = query
  end

  def self.find_origin_src_by_url(url:)
    urls = [url].flatten.uniq
    origin_srces = []
    urls.each do |u|
      origin_src, query = Datapool::ResourceMetum.url_partition(url: u)
      origin_srces << origin_src
    end
    return self.where(origin_src: origin_srces)
  end

  def self.constract(url:, title:, type: ,check_file: false, file_genre: nil, options: {})
    if Datapool::ImageMetum.imagefile?(url)
      if self.base_class.to_s == "Datapool::ImageMetum"
        return self.constract(url: url, title: title, check_image_file: check_file, options: options)
      else
        return Datapool::WebSiteImageMetum.constract(url: url, title: title, check_image_file: check_file, options: options)
      end
    elsif Datapool::PdfMetum.pdffile?(url)
      if self.base_class.to_s == "Datapool::PdfMetum"
        return self.new(url: url, title: title, check_image_file: check_file, options: options)
      else
        return Datapool::PdfMetum.new(url: url, title: title, check_image_file: check_file, options: options)
      end
    elsif Datapool::AudioMetum.audiofile?(url)
      if self.base_class.to_s == "Datapool::AudioMetum"
        return self.constract(url: url, title: title, file_genre: file_genre, options: options)
      else
        return Datapool::WebSiteAudioMetum.constract(url: url, title: title, file_genre: file_genre, options: options)
      end
    elsif Datapool::VideoMetum.videofile?(url)
      if self.base_class.to_s == "Datapool::VideoMetum"
        return self.constract(url: url, title: title, file_genre: file_genre, options: options)
      else
        return Datapool::VideoMetum.constract(url: url, title: title, file_genre: file_genre, options: options)
      end
    else
      return Datapool::Website.constract(url: url, title: title, options: options)
    end
  end

  def self.import_resources!(resources:)
    clazz_imports = {}
    resources.each do |resource|
      next unless resource.kind_of?(Datapool::ResourceMetum)
      if resource.kind_of?(Datapool::ImageMetum)
        if clazz_imports[Datapool::ImageMetum].blank?
          clazz_imports[Datapool::ImageMetum] = []
        end
        clazz_imports[Datapool::ImageMetum] << resource
      elsif resource.kind_of?(Datapool::PdfMetum)
        if clazz_imports[Datapool::PdfMetum].blank?
          clazz_imports[Datapool::PdfMetum] = []
        end
        clazz_imports[Datapool::PdfMetum] << resource
      elsif resource.kind_of?(Datapool::AudioMetum)
        if clazz_imports[Datapool::AudioMetum].blank?
          clazz_imports[Datapool::AudioMetum] = []
        end
        clazz_imports[Datapool::AudioMetum] << resource
      elsif resource.kind_of?(Datapool::VideoMetum)
        if clazz_imports[Datapool::VideoMetum].blank?
          clazz_imports[Datapool::VideoMetum] = []
        end
        clazz_imports[Datapool::VideoMetum] << resource
      else
        if clazz_imports[Datapool::Website].blank?
          clazz_imports[Datapool::Website] = []
        end
        clazz_imports[Datapool::Website] << resource
      end
    end

    clazz_imports.each do |clazz, imports|
      src_resources = clazz.find_origin_src_by_url(url: imports.map(&:src).uniq).index_by(&:src)
      import_resources = imports.select{|import| src_resources[import.src].blank? }
      if import_resources.present?
        clazz.import!(import_resources)
      end
    end
  end

  def save_filename
    return SecureRandom.hex + File.extname(self.try(:original_filename).to_s)
  end

  def set_original_filename(filename)
    if filename.size > 255
      self.original_filename = SecureRandom.hex + File.extname(filename)
    else
      self.original_filename = filename
    end
  end

  def self.crawler_routine!
    Homepage::UploadJobQueue.cleanup!
    Datapool::Website.resource_crawl!
    Datapool::ImageMetum.backup!
  end

  def self.upload_to_s3(binary, filepath)
    s3 = Aws::S3::Client.new
    s3.put_object(bucket: "taptappun",body: binary, key: filepath, acl: "public-read")
  end

  def download_resource_response
    aurl = Addressable::URI.parse(self.src)
    client = HTTPClient.new
    client.connect_timeout = 300
    client.send_timeout    = 300
    client.receive_timeout = 300
    client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response = nil
    begin
      response = client.get(aurl.to_s)
    rescue => e
      Rails.logger.warn("download error #{self.class.to_s}_#{self.id}:#{aurl.to_s}")
    end
    return response
  end

  def self.compress_to_zip(zip_filepath:, resources: [])
    filename_hash = {}
    Zip::OutputStream.open(zip_filepath) do |stream|
      resources.each do |resource|
        response = resource.download_resource_response
        next if response.blank? || (response.status >= 300 && !(302..304).cover?(response.status))
        if filename_hash[resource.save_filename].nil?
          stream.put_next_entry(resource.save_filename)
        else
          stream.put_next_entry(SecureRandom.hex + File.extname(resource.save_filename))
        end
        stream.print(response.body)
        filename_hash[resource.save_filename] = resource
      end
    end
    return zip_filepath
  end

  private
  def self.url_partition(url:)
    aurl = Addressable::URI.parse(url)
    pure_url = aurl.origin.to_s + aurl.path.to_s
    if pure_url.size > 255
      word_counter = 0
      srces, other_pathes = pure_url.split("/").partition do |word|
        word_counter = word_counter + word.size + 1
        word_counter <= 255
      end
      return srces.join("/"), other_pathes.join("/")
    else
      return pure_url, aurl.query
    end
  end
end
