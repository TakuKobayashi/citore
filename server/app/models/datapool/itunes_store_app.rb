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

class Datapool::ItunesStoreApp < Datapool::StoreProduct
  URLS_HASH = {
    top_grossing: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-grossing/all/300/explicit.json",
    top_free: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-free/all/300/explicit.json",
    top_paid: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-paid/all/300/explicit.json",
    new_games: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/new-games-we-love/all/300/explicit.json",
    new_apps: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/new-apps-we-love/all/300/explicit.json",
    top_grossing_tablet: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-grossing-ipad//all/300/explicit.json",
    top_free_tablet: "https://rss.itunes.apple.com/api/v1/jp/top-free-ipad/top-free/all/300/explicit.json",
    top_free_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-free-mac-apps/all/200/explicit.json",
    top_grossing_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-grossing-mac-apps/all/200/explicit.json",
    top_all_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-mac-apps/all/200/explicit.json",
    top_paid_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-paid-mac-apps/all/200/explicit.json",
  }

  def self.update_rankings!
    URLS_HASH.each do |category, crawl_url|
      response_hash = ApplicationRecord.request_and_parse_json(crawl_url)
      results = response_hash["feed"]["results"] || []
      app_arr = []
      product_id_app = Datapool::ItunesStoreApp.where(product_id: results.map{|r| r["id"] }).index_by(&:product_id)
      results.each do |result|
        if product_id_app.has_key?(result["id"])
          app_ins = product_id_app[result["id"]]
          app_ins.title = result["name"]
          app_ins.icon_url = result["artworkUrl100"]
          app_ins.publisher_name = result["artistName"]
        else
          app_ins = Datapool::ItunesStoreApp.new(
            publisher_name: result["artistName"],
            product_id: result["id"],
            title: result["name"],
            icon_url: result["artworkUrl100"],
            url: result["url"],
            published_at: Time.parse(result["releaseDate"]),
            options: {}
          )
        end
        app_ins.options = app_ins.options.merge({
          genres: result["genres"],
          kind: result["kind"],
          summary: result["summary"],
          publiser_url: result["artistUrl"],
          primary_genre: result["primaryGenreName"],
          artist_id: result["artistId"],
          bundle_id: result["bundleId"],
          price: result["price"]
        }).delete_if{|k, v| v.nil? }
        app_ins.set_details
        app_arr << app_ins
      end
      Datapool::ItunesStoreApp.import!(app_arr, on_duplicate_key_update: [:title, :description, :icon_url, :publisher_name, :options])
      product_id_app = Datapool::ItunesStoreApp.where(product_id: results.map{|r| r["id"] }).index_by(&:product_id)
      rankings = []
      results.each_with_index do |result, index|
        rankings << product_id_app[result["id"]].rankings.new(category: category, rank: index + 1)
      end
      Datapool::StoreRanking.import(rankings)
    end
  end

  def set_details
    parsed_html = ApplicationRecord.request_and_parse_html(self.url)
    rating_field = parsed_html.css(".rating").children
    if self.description.blank?
      self.description = parsed_html.css(".center-stack").css("p").detect{|h| h[:itemprop] == "description" }.try(:to_html)
    end
    self.review_count = rating_field.first.try(:text).to_i
    self.average_score = rating_field.detect{|h| h[:itemprop] == "ratingValue" }.try(:text).to_f
  end
end
