# == Schema Information
#
# Table name: datapool_store_products
#
#  id             :integer          not null, primary key
#  type           :string(255)
#  publisher_name :string(255)
#  product_id     :string(255)      not null
#  title          :string(255)      not null
#  description    :text(65535)
#  url            :text(65535)      not null
#  icon_url       :string(255)
#  review_count   :integer          default(0), not null
#  average_score  :float(24)        default(0.0), not null
#  published_at   :datetime
#  options        :text(65535)
#
# Indexes
#
#  store_product_published_at_index  (published_at)
#  store_product_unique_index        (product_id,type) UNIQUE
#

class Datapool::GooglePlayApp < Datapool::StoreProduct
  URLS_HASH = {
    top_grossing: "https://play.google.com/store/apps/collection/topgrossing?hl=ja",
    top_grossing_game: "https://play.google.com/store/apps/category/GAME/collection/topgrossing?hl=ja",
    top_free: "https://play.google.com/store/apps/collection/topselling_free?hl=ja",
    top_free_game: "https://play.google.com/store/apps/category/GAME/collection/topselling_free?hl=ja",
    top_paid: "https://play.google.com/store/apps/collection/topselling_paid?hl=ja",
    top_paid_game: "https://play.google.com/store/apps/category/GAME/collection/topselling_paid?hl=ja",
    new_games: "https://play.google.com/store/apps/category/GAME/collection/topselling_new_free?hl=ja",
    new_games_paid: "https://play.google.com/store/apps/category/GAME/collection/topselling_new_paid?hl=ja",
    new_apps: "https://play.google.com/store/apps/collection/topselling_new_free?hl=ja",
    new_apps_paid: "https://play.google.com/store/apps/collection/topselling_new_paid?hl=ja"
  }

  RANKING_PERPAGE = 100
  RANKING_MAXPAGE = 500

  def self.update_rankings!
    URLS_HASH.each do |category, crawl_url|
      page_counter = 0
      while(page_counter <= RANKING_MAXPAGE) do
        html = ApplicationRecord.request_and_parse_html(crawl_url, :post, {start: page_counter, num: RANKING_PERPAGE})
        contents = html.css(".card-content")
        ids = contents.map do |c|
          url = ApplicationRecord.merge_full_url(src: c.css(".title").first[:href], org: crawl_url)
          url.query_values["id"]
        end
        ids.compact!
        product_id_app = Datapool::GooglePlayApp.where(product_id: ids).index_by(&:product_id)
        contents.each do |content|
          ads_url = ApplicationRecord.merge_full_url(src: content.css(".title").first[:href], org: crawl_url)
          if product_id_app.has_key?(ads_url.query_values["id"])
            app_ins = product_id_app[ads_url.query_values["id"]]
          else
            app_ins = Datapool::GooglePlayApp.new(
              product_id: ads_url.query_values["id"],
              url: ads_url.to_s,
              options: {}
            )
          end
          app_ins.icon_url = ApplicationRecord.merge_full_url(src: content.css("img").first[:src], org: crawl_url).to_s
          app_ins.title = content.css(".title").first[:title]
          app_ins.publisher_name = content.css(".subtitle").first[:title]

          artist_url = ApplicationRecord.merge_full_url(src: content.css(".subtitle").first[:href], org: crawl_url)
          app_ins.options = app_ins.options.merge({
            publiser_url: artist_url.to_s,
            artist_id: artist_url.query_values["id"],
            price: content.css(".price-container").css(".display-price").last.try(:text),
            summary: ApplicationRecord.basic_sanitize(content.css(".description").text).strip
          }).delete_if{|k, v| v.blank? }
          app_ins.set_details
          app_ins.save!
        end
        product_id_app = Datapool::GooglePlayApp.where(product_id: ids).index_by(&:product_id)
        rankings = []
        ids.each_with_index do |product_id, index|
          rankings << product_id_app[product_id].rankings.new(category: category, rank: page_counter + index + 1)
        end
        Datapool::StoreRanking.import(rankings)
        page_counter += RANKING_PERPAGE
      end
    end
  end

  def set_details
    parsed_html = ApplicationRecord.request_and_parse_html(self.url)
    rating_field = parsed_html.css(".score-container").children
    detail_contents = parsed_html.css(".details-wrapper").css(".content")

    self.description = ApplicationRecord.basic_sanitize(parsed_html.css(".description").css(".text-body").children.select{|c| c.text.strip.present? }.map{|c| c.children.to_html }.join)
    self.review_count = rating_field.detect{|h| h[:itemprop] == "ratingCount" }.try(:text).to_i
    self.average_score = rating_field.detect{|h| h[:itemprop] == "ratingValue" }.try(:text).to_f

    screenshot_urls = parsed_html.css(".screenshot-container").css("img").map{|h| ApplicationRecord.merge_full_url(src: h[:src], org: self.url).to_s }.select do |url|
      fi = FastImage.new(url)
      fi.type.present?
    end

    self.options = self.options.merge({
      screen_shots: screenshot_urls,
      genre: parsed_html.css(".details-info").css(".category").text.strip,
      download_num: detail_contents.detect{|c| c[:itemprop] == "numDownloads"}.try(:text).to_s.strip.gsub(",", ""),
      version: detail_contents.detect{|c| c[:itemprop] == "softwareVersion"}.try(:text).to_s.strip,
    })
  end
end
