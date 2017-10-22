class Datapool::ResourceMetum < ApplicationRecord
  self.abstract_class = true

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

  def save_filename
    return filename + File.extname(self.try(:original_filename).to_s)
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
    response = client.get(aurl.to_s)
    return response
  end

  def self.compress_to_zip(zip_filepath:, resources: [])
    filename_hash = {}
    Zip::OutputStream.open(zip_filepath) do |stream|
      resources.each do |resource|
        response = resource.download_resource_response
        next if (response.status >= 300 && !(302..304).cover?(response.status))
        if filename_hash[resource.save_filename].nil?
          stream.put_next_entry(resource.save_filename)
        else
          stream.put_next_entry(SecureRandom.hex + File.extname(response.save_filename))
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
