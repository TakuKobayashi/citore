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

  def self.update_rankings!
    URLS_HASH.each do |category, crawl_url|
      html = ApplicationRecord.request_and_parse_html(crawl_url)
      contents = html.css(".card-content")
      app_arr = []
      product_id_app = Datapool::GooglePlayApp.where(product_id: contents.map{|r| r["id"] }).index_by(&:product_id)
      contents.each do |content|
        ads_url = ApplicationRecord.merge_full_url(src: content.css(".title").first[:href], org: crawl_url)
        if product_id_app.has_key?(result["id"])
          app_ins = product_id_app[result["id"]]
        else
          app_ins = Datapool::GooglePlayApp.new(
            product_id: result["id"],
            url: result["url"]
            options: {}
          )
        end
        app_ins.icon_url = ApplicationRecord.merge_full_url(src: content.css("img").first[:src], org: crawl_url).to_s
        app_ins.title = content.css(".title").first[:title]
        app_ins.url = ads_url.to_s
        app_ins.publisher_name = content.css(".subtitle").first[:title]
        app_ins.options = app_ins.options.merge({
          publiser_url: ApplicationRecord.merge_full_url(src: content.css(".subtitle").first[:url], org: crawl_url).to_s,
          artist_id: result["artistId"]
        }).delete_if{|k, v| v.nil? }
        app_ins.set_details
        app_arr << app_ins
      end
      Datapool::GooglePlayApp.import!(app_arr, on_duplicate_key_update: [:title, :description, :icon_url, :publisher_name, :options])
      product_id_app = Datapool::GooglePlayApp.where(product_id: results.map{|r| r["id"] }).index_by(&:product_id)
      rankings = []
      results.each_with_index do |result, index|
        rankings << product_id_app[result["id"]].rankings.new(category: category, rank: index + 1)
      end
      Datapool::StoreRanking.import(rankings)
    end
  end

  def set_details
    parsed_html = ApplicationRecord.request_and_parse_html(self.url)
    rating_field = parsed_html.css(".score-container").children
    self.description = parsed_html.css(".description").css(".text-body").children.select{|c| c.text.strip.present? }.map{|c| c.children.to_html }.join
    self.review_count = rating_field.detect{|h| h[:itemprop] == "ratingCount" }.try(:text).to_i
    self.average_score = rating_field.detect{|h| h[:itemprop] == "ratingValue" }.try(:text).to_f
  end
end
