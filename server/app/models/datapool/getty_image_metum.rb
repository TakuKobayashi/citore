# == Schema Information
#
# Table name: datapool_image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  other_src         :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_image_meta_on_origin_src  (origin_src)
#  index_datapool_image_meta_on_title       (title)
#

class Datapool::GettyImageMetum < Datapool::ImageMetum
  GETTY_IMAGES_API_URL = "https://api.gettyimages.com/v3/search/images"

  def self.crawl_images!(keyword:)
    all_images = []
    page = 1
    loop do
      images = []
      json = RequestParser.request_and_parse_json(url: GETTY_IMAGES_API_URL, params: {phrase: keyword, page_size: 100, page: page, fields: "detail_set"},  headers: {"Api-Key" => ENV.fetch('GETTY_IMAGES_STANDARD_KEY', '')})
      json["images"].each do |data_hash|
        image_url = data_hash["display_sizes"].map{|dhash| Addressable::URI.parse(dhash["uri"].to_s) }.map{|url| url.origin + url.path }.uniq.sample
        image = self.constract(
          url: image_url,
          title: data_hash["title"],
          options: {
            keywords: keyword.to_s,
            id: data_hash["id"],
            referral_destinations: data_hash["referral_destinations"],
            artist: data_hash["artist"],
            asset_family: data_hash["asset_family"]
          }
        )
        images << image
      end
      break if images.blank?
      self.import_resources!(resources: images)
      all_images += images
      break if json["result_count"].to_i <= (page * 100) + images.size
      page = page + 1
      sleep 1
    end
    return all_images
  end
end
