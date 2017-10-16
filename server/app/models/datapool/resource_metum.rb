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

  def self.crawler_routine!
    Homepage::UploadJobQueue.cleanup!
    Datapool::Website.resource_crawl!
    Datapool::ImageMetum.backup!
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
