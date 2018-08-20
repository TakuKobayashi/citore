# == Schema Information
#
# Table name: datapool_image_meta
#
#  id                :bigint(8)        not null, primary key
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

class Datapool::WebSiteImageMetum < Datapool::ImageMetum
  def self.crawl_images!(url:, page_key: nil, start_page: 1, end_page: 1, filter: nil, request_method: :get)
    images = []
    (start_page.to_i..end_page.to_i).each do |page|
      address_url = Addressable::URI.parse(url.to_s)
      if page_key.present?
        queries = address_url.query_values || {}
        address_url.query_values = queries.merge(page_key => page)
      end
      break unless address_url.scheme.to_s.include?("http")
      doc = RequestParser.request_and_parse_html(url: address_url.to_s, method: request_method, options: {:follow_redirect => true})
      images += self.generate_objects_from_parsed_html(doc: doc, filter: filter, from_site_url: address_url.to_s)
    end
    images.uniq!(&:src)
    self.import_resources!(resources: images)
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
      image_url = Addressable::URI.parse(Sanitizer.basic_sanitize(d["src"].to_s.gsub(/(\r\n|\r|\n)/, "")))
      if image_url.nil?
        Rails.logger.warn("not exists image_url")
        next
      end
      # base64encodeされたものはschemeがdataになる
      if image_url.scheme != "data"
        image_url = WebNormalizer.merge_full_url(src: image_url.to_s, org: from_site_url.to_s)
      end
      next if image_urls.include?(image_url.to_s)
      image_urls << image_url.to_s
      image_title = Sanitizer.basic_sanitize(title.to_s)
      if image_title.blank?
        image_title = Sanitizer.basic_sanitize(doc.title.to_s)
      end
      image = self.constract(
        url: image_url.to_s,
        title: image_title,
        check_file: true,
        options: {
          from_url: from_site_url.to_s
        }
      )
      images << image
    end
    # constractできなかったものはnullが入っているので
    return images.compact
  end
end
