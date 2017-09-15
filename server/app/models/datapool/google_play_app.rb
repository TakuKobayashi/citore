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

  end

  def self.import_review!
  end
end
