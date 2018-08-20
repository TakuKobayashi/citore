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

class Datapool::GoogleImageSearch < Datapool::ImageMetum
  GOOGLE_SEARCH_URL = "https://www.google.co.jp/search"

  def self.crawl_images!(keyword:)
    all_images = []
    counter = 0
    loop do
      search_url = Addressable::URI.parse(GOOGLE_SEARCH_URL)
      #tbm=ischは画像検索の結果のタブ, ijnはどうやる100件ごとのページ番号のよう
      search_url.query_values = {q: keyword, tbm: "isch", start: counter, ijn: (counter / 100).to_i}
      images = self.import_search_images!(search_url: search_url.to_s, number: counter, keyword: keyword)
      break if images.blank?
      all_images += images
      counter = counter + images.size
    end
    return all_images
  end

  # 画像ファイルの拡張子の後ろに何かゴミがついていることがあるので、それは取り除く
  def self.laundering_url_path(url:)
    image_url = Addressable::URI.parse(url.to_s)
    pathes = image_url.path.split("/")
    if pathes.size > 0
      pathes[pathes.size - 1] = self.match_filename(image_url.to_s)
    else
      pathes = [("/" + self.match_filename(image_url.to_s))]
    end
    image_url.path = pathes.join("/")
    return image_url.to_s
  end

  def self.import_search_images!(search_url:, keyword:, number: 0, options: {})
    images = []
    websites = []
    img_dom = RequestParser.request_and_parse_html(url: search_url.to_s, options: {:follow_redirect => true})
    searched_urls = img_dom.css("a").map{|a| Addressable::URI.parse(a["href"].to_s) }
    web_attributes = img_dom.css(".rg_meta").map do |a|
      begin
        JSON.parse(a.text)
      rescue JSON::ParserError => e
        {}
      end
    end
    return [] if searched_urls.blank?
    searched_thumbnail_urls = img_dom.css("img").map do |img|
      if img["data-src"].blank?
        img["data-src"]
      else
        img["src"]
      end
    end
    counter = 0
    searched_urls.each_with_index do |url, index|
      link_metum = url.query_values
      next if link_metum["imgurl"].blank? && link_metum["imgrefurl"].blank?
      image_url = self.laundering_url_path(url: link_metum["imgurl"].to_s)
      split_keywords = keyword.to_s.split(" ")
      image = self.constract(
        url: image_url.to_s,
        title: split_keywords.first,
        check_file: true,
        options: {
          keywords: keyword.to_s,
          number: number + counter + 1
        }.merge(options)
      )
      if image.blank?
        image = self.constract(
          url: searched_thumbnail_urls[index].to_s,
          title: split_keywords.first,
          check_file: true,
          options: {
            keyword: keyword.to_s,
            number: number + counter + 1
          }.merge(options)
        )
      end
      if image.present?
        images << image
        web_attribute = web_attributes[index] || {}
        websites << Datapool::GoogleSearchWebsite.constract(url: link_metum["imgrefurl"].to_s, title: web_attribute["pt"].to_s, options: {keyword: keyword.to_s, number: number + counter + 1})
        counter = counter + 1
      end
    end
    self.import_resources!(resources: images + websites)
    return images
  end
end
