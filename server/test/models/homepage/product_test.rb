# == Schema Information
#
# Table name: homepage_products
#
#  id              :integer          not null, primary key
#  category        :integer          default(0), not null
#  title           :string(255)      not null
#  description     :text(65535)
#  thumbnail_url   :string(255)
#  large_image_url :string(255)
#  url             :string(255)
#  pubulish_at     :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_homepage_products_on_pubulish_at  (pubulish_at)
#

require 'test_helper'

class Homepage::ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
