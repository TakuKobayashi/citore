# == Schema Information
#
# Table name: datapool_reviews
#
#  id                        :integer          not null, primary key
#  datapool_store_product_id :integer
#  user_name                 :string(255)
#  score                     :float(24)        default(0.0), not null
#  message                   :text(65535)      not null
#  options                   :text(65535)
#
# Indexes
#
#  reviews_product_url_index  (datapool_store_product_id)
#

require 'test_helper'

class Datapool::ReviewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
