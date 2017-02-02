# == Schema Information
#
# Table name: categorised_words
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  large_category  :integer          default("large_unknown"), not null
#  medium_category :integer          default("medium_unknown"), not null
#  detail_category :string(255)      not null
#  body            :text(65535)      not null
#  relation_id_csv :text(65535)
#
# Indexes
#
#  word_categories_index  (large_category,medium_category,detail_category)
#

require 'test_helper'

class CategorisedWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
