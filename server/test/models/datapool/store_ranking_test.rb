# == Schema Information
#
# Table name: datapool_store_rankings
#
#  id                        :integer          not null, primary key
#  datapool_store_product_id :integer          not null
#  category                  :integer          default(0), not null
#  rank                      :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  store_rankings_created_at_index  (created_at)
#  store_rankings_product_id_index  (datapool_store_product_id)
#

require 'test_helper'

class Datapool::StoreRankingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
