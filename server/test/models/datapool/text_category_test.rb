# == Schema Information
#
# Table name: datapool_text_categories
#
#  id                   :integer          not null, primary key
#  datapool_text_id     :integer          not null
#  datapool_category_id :integer          not null
#
# Indexes
#
#  datapool_text_category_relation_index  (datapool_text_id,datapool_category_id) UNIQUE
#

require 'test_helper'

class Datapool::TextCategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
