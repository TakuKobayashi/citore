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

class Datapool::VideoMetum < Datapool::ResourceMetum
  serialize :options, JSON

  enum data_category: {
    file: 0,
    streaming: 1
  }

  CRAWL_IMAGE_ROOT_PATH = "project/crawler/videos/"

  #TODO check
  def self.videofile?(url)
    return false
  end
end
