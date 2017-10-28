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
    top_free_tablet: "https://rss.itunes.apple.com/api/v1/jp/ios-apps/top-free-ipad/all/300/explicit.json",
    top_free_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-free-mac-apps/all/200/explicit.json",
    top_grossing_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-grossing-mac-apps/all/200/explicit.json",
    top_all_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-mac-apps/all/200/explicit.json",
    top_paid_pc: "https://rss.itunes.apple.com/api/v1/jp/macos-apps/top-paid-mac-apps/all/200/explicit.json",
  }

  def self.update_rankings!
    URLS_HASH.each do |category, crawl_url|
      response_hash = ApplicationRecord.request_and_parse_json(url: crawl_url)
      next if response_hash["feed"].blank?
      results = response_hash["feed"]["results"] || []
      product_id_app = Datapool::ItunesStoreApp.where(product_id: results.map{|r| r["id"] }).index_by(&:product_id)
      results.each do |result|
        if product_id_app.has_key?(result["id"])
          app_ins = product_id_app[result["id"]]
        else
          app_ins = Datapool::ItunesStoreApp.new(
            product_id: result["id"],
            url: result["url"],
            options: {}
          )
        end
        app_ins.title = result["name"]
        app_ins.icon_url = result["artworkUrl100"]
        app_ins.publisher_name = result["artistName"]
        app_ins.options = app_ins.options.merge({
          genres: result["genres"],
          kind: result["kind"],
          publisher_url: result["artistUrl"],
          primary_genre: result["primaryGenreName"],
          artist_id: result["artistId"],
          bundle_id: result["bundleId"],
          price: result["price"],
          released_at: Time.parse(result["releaseDate"])
        }).delete_if{|k, v| v.nil? }
        app_ins.set_details
        if app_ins.description.blank?
          app_ins.description = result["summary"]
        end
        app_ins.save!
      end
      product_id_app = Datapool::ItunesStoreApp.where(product_id: results.map{|r| r["id"] }).index_by(&:product_id)
      rankings = []
      results.each_with_index do |result, index|
        rankings << product_id_app[result["id"]].rankings.new(category: category, rank: index + 1)
      end
      Datapool::StoreRanking.import(rankings)
    end
  end

  def set_details
    parsed_html = ApplicationRecord.request_and_parse_html(url: self.url)
    rating_field = parsed_html.css(".rating").css("span")
    product_info_fields= parsed_html.css("#left-stack").css("ul.list").css("li").css("span")

    if self.description.blank?
      self.description = parsed_html.css(".center-stack").css("p").detect{|h| h[:itemprop] == "description" }.try(:to_html)
    end
    self.review_count = rating_field.detect{|h| h[:itemprop] == "reviewCount" }.try(:text).to_i
    self.average_score = rating_field.detect{|h| h[:itemprop] == "ratingValue" }.try(:text).to_f
    date_string = product_info_fields.detect{|l| l[:itemprop] == "datePublished"}.try(:text).to_s.strip
    if date_string.present?
      self.published_at = Time.strptime(date_string, "%Y年%m月%d日")
    end
    iphone_screenshot_urls = parsed_html.css(".iphone-screen-shots").css("img").map{|h| ApplicationRecord.merge_full_url(src: h[:src], org: self.url).to_s }.select do |url|
      fi = FastImage.new(url)
      fi.type.present?
    end

    ipad_screenshot_urls = parsed_html.css(".ipad-screen-shots").css("img").map{|h| ApplicationRecord.merge_full_url(src: h[:src], org: self.url).to_s }.select do |url|
      fi = FastImage.new(url)
      fi.type.present?
    end

    self.options = self.options.merge({
      screen_shots: iphone_screenshot_urls,
      tablets_screen_shots: ipad_screenshot_urls,
      version: product_info_fields.detect{|l| l[:itemprop] == "softwareVersion"}.try(:text)
    })
  end

  def self.import_reviews!
    Datapool::ItunesStoreApp.includes(:reviews).find_each do |store|
      response_hash = ApplicationRecord.request_and_parse_json(url: "https://itunes.apple.com/jp/rss/customerreviews/id=" + store.product_id + "/json")
      next if response_hash["feed"].blank?
      entries = response_hash["feed"]["entry"] || []
      next if entries.instance_of?(Hash)
      review_instances = []
      id_review = store.reviews.where(review_id: entries.map{|e| (e["id"] || {})["label"] }.compact).index_by{|s| s.review_id}
      entries.each do |entry|
        next if !entry["id"].has_key?("label") ||
          entry["content"].nil? ||
          entry["im:rating"].nil?

        user_attributes = (entry["author"] || {})
        review_id = (entry["id"] || {})["label"]
        if id_review.has_key?(review_id)
          review_ins = id_review[review_id]
        else
          review_ins = store.reviews.new(review_id: review_id, options: {})
        end
        review_ins.title = ApplicationRecord.basic_sanitize((entry["title"] || {})["label"].to_s)
        review_ins.user_name = ApplicationRecord.basic_sanitize((user_attributes["name"] || {})["label"].to_s)
        review_ins.score = (entry["im:rating"] || {})["label"].to_f
        review_ins.message = ApplicationRecord.basic_sanitize((entry["content"] || {})["label"].to_s)
        review_ins.options = review_ins.options.merge({
          user_review_url: (user_attributes["url"] || {})["label"].to_s,
          version: (entry["im:version"] || {})["label"],
          vote_sum: (entry["im:voteSum"] || {})["label"].to_i,
          vote_count: (entry["im:voteCount"] || {})["label"].to_i
        }).delete_if{|k, v| v.nil? }
        review_instances << review_ins
      end
      Datapool::Review.import(review_instances, on_duplicate_key_update: [:title, :user_name, :score, :message, :options])
    end
  end
end
