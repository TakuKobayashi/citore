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

class Datapool::GettyImageMetum < Datapool::ImageMetum
  GETTY_IMAGES_API_URL = "https://api.gettyimages.com/v3/search/images"

  def self.crawl_images!(keyword:)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    all_images = []
    page = 1
    loop do
      images = []
      json = ApplicationRecord.request_and_parse_json(url: GETTY_IMAGES_API_URL, params: {phrase: keyword, page_size: 100, page: page, fields: "detail_set"},  headers: {"Api-Key" => apiconfig["getty_images"]["standard"]["key"]})
      json["images"].each do |data_hash|
        image_url = data_hash["display_sizes"].map{|dhash| Addressable::URI.parse(dhash["uri"].to_s) }.map{|url| url.origin + url.path }.uniq.sample
        image = self.constract(
          image_url: image_url,
          title: data_hash["title"],
          check_image_file: false,
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
      src_images = Datapool::ImageMetum.find_origin_src_by_url(url: images.map(&:src)).index_by(&:src)
      import_images = images.select{|image| src_images[image.src].blank? }
      if import_images.present?
        self.import!(import_images)
      end
      all_images += images
      break if json["result_count"].to_i <= (page * 100) + images.size
      page = page + 1
      sleep 1
    end
    return all_images
  end
end
