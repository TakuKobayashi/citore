# == Schema Information
#
# Table name: datapool_video_meta
#
#  id              :integer          not null, primary key
#  type            :string(255)
#  title           :string(255)      not null
#  front_image_url :text(65535)
#  data_category   :integer          default("file"), not null
#  bitrate         :integer          default(0), not null
#  origin_src      :string(255)      not null
#  query           :text(65535)
#  options         :text(65535)
#
# Indexes
#
#  index_datapool_video_meta_on_origin_src  (origin_src)
#  index_datapool_video_meta_on_title       (title)
#

class Datapool::VideoMetum < ApplicationRecord
  serialize :options, JSON

  enum data_category: {
    file: 0,
    streaming: 1
  }

  CRAWL_IMAGE_ROOT_PATH = "project/crawler/videos/"

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
end
