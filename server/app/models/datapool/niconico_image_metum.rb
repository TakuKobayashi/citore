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

class Datapool::NiconicoImageMetum < Datapool::ImageMetum
  NICONICO_CONTENT_API_URL = "http://api.search.nicovideo.jp/api/v2/illust/contents/search"

  def self.crawl_images!(keyword:)
    all_images = []
    counter = 0
    loop do
      images = []
      json = ApplicationRecord.request_and_parse_json(url: NICONICO_CONTENT_API_URL, params: {q: keyword, targets: "title,description,tags", _context: "taptappun", fields: "contentId,title,tags,categoryTags,thumbnailUrl", _sort: "-startTime", _offset: counter, _limit: 100})
      json["data"].each do |data_hash|
        image = self.constract(
          image_url: data_hash["thumbnailUrl"],
          title: data_hash["title"],
          check_image_file: false,
          options: {
            keywords: keyword.to_s,
            content_id: data_hash["contentId"],
            tags: data_hash["tags"].to_s.split(" "),
            category_tags: data_hash["categoryTags"].to_s.split(" ")
          }
        )
        images << image
      end
      break if images.blank?
      src_images = Datapool::ImageMetum.find_origin_src_by_url(url: images.map(&:src)).index_by(&:src)
      import_images = images.select{|image| src_images[image.src].blank? }
      if import_images.present?
        self.import!(import_images)
      end
      all_images += images
      counter = counter + images.size
      break if json["meta"]["totalCount"].to_i <= counter
    end
    return all_images
  end
end
