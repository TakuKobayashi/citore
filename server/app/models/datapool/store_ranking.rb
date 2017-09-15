# == Schema Information
#
# Table name: datapool_store_rankings
#
#  id                        :integer          not null, primary key
#  datapool_store_product_id :integer          not null
#  category                  :integer          default("top_grossing"), not null
#  rank                      :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  store_rankings_created_at_index  (created_at)
#  store_rankings_product_id_index  (datapool_store_product_id)
#

class Datapool::StoreRanking < ApplicationRecord
  enum category: (Datapool::ItunesStoreApp::URLS_HASH.keys | Datapool::GooglePlayApp::URLS_HASH.keys)
  belongs_to :store_product, class_name: 'Datapool::StoreProduct', foreign_key: :datapool_store_product_id, required: false
end
