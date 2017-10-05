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

class Datapool::WebSiteImageMetum < Datapool::ImageMetum
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
    image_urls = []
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
      # base64encodeされたものはschemeがdataになる
      if image_url.scheme != "data"
        image_url = ApplicationRecord.merge_full_url(src: image_url, org: from_site_url)
      end
      next if image_urls.include?(image_url.to_s)
      image_urls << image_url.to_s
      image = self.constract(
        image_url: image_url.to_s,
        title: title.to_s,
        check_image_file: true,
        options: {
          from_url: from_site_url
        }
      )
      images << image
    end
    return images
  end
end