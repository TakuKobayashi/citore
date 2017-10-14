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

class Datapool::GoogleImageSearch < Datapool::ImageMetum
  GOOGLE_SEARCH_URL = "https://www.google.co.jp/search"

  def self.crawl_images!(keyword:)
    all_images = []
    counter = 0
    loop do
      search_url = Addressable::URI.parse(GOOGLE_SEARCH_URL)
      #tbm=ischは画像検索の結果のタブ, ijnはどうやる100件ごとのページ番号のよう
      search_url.query_values = {q: keyword, tbm: "isch", start: counter, ijn: (counter / 100).to_i}
      images = self.import_search_images!(search_url: search_url.to_s, keyword: keyword)
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
    pathes[pathes.size - 1] = self.match_image_filename(image_url.to_s)
    image_url.path = pathes.join("/")
    return image_url.to_s
  end

  def self.import_search_images!(search_url:, keyword:, options: {})
    images = []
    websites = []
    img_dom = ApplicationRecord.request_and_parse_html(search_url.to_s)
    searched_urls = img_dom.css("a").map{|a| Addressable::URI.parse(a["href"].to_s) }
    return [] if searched_urls.blank?
    searched_thumbnail_urls = img_dom.css("img").map do |img|
      if img["data-src"].blank?
        img["data-src"]
      else
        img["src"]
      end
    end
    searched_urls.each_with_index do |url, index|
      link_metum = url.query_values
      next if link_metum["imgurl"].blank? && link_metum["imgrefurl"].blank?
      image_url = self.laundering_url_path(url: link_metum["imgurl"].to_s)
      split_keywords = keyword.to_s.split(" ")
      image = self.constract(
        image_url: image_url.to_s,
        title: split_keywords.first,
        check_image_file: true,
        options: {
          keywords: keyword.to_s
        }.merge(options)
      )
      if image.blank?
        image = self.constract(
          image_url: searched_thumbnail_urls[index].to_s,
          title: split_keywords.first,
          check_image_file: true,
          options: {
            keyword: keyword.to_s
          }.merge(options)
        )
      end
      if image.present?
        images << image
        websites << Datapool::GoogleSearchWebsite.constract(url: link_metum["imgrefurl"].to_s, options: {keyword: keyword.to_s})
      end
    end
    src_images = Datapool::ImageMetum.where(origin_src: images.map(&:origin_src)).index_by(&:src)
    src_websites = Datapool::GoogleSearchWebsite.where(origin_src: websites.map(&:origin_src)).index_by(&:src)
    import_images = images.select{|image| src_images[image.src].blank? }
    import_websites = websites.select{|website| src_websites[website.src].blank? }
    self.import!(import_images)
    Datapool::GoogleSearchWebsite.import!(import_websites)
    return images
  end
end
