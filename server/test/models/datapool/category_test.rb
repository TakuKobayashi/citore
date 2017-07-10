# == Schema Information
#
# Table name: datapool_categories
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  defined_number     :integer          default(0), not null
#  parent_category_id :integer
#
# Indexes
#
#  index_datapool_categories_on_defined_number      (defined_number)
#  index_datapool_categories_on_name                (name) UNIQUE
#  index_datapool_categories_on_parent_category_id  (parent_category_id)
#

require 'test_helper'

class Datapool::CategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
