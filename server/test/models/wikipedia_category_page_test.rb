# == Schema Information
#
# Table name: wikipedia_category_pages
#
#  id                :integer          not null, primary key
#  wikipedia_page_id :integer          default(0), not null
#  category_title    :string(255)      default(""), not null
#  sortkey           :string(255)      default(""), not null
#  timestamp         :datetime
#  sortkey_prefix    :string(255)      default(""), not null
#  collation         :string(255)      default(""), not null
#  category_type     :integer          default("page"), not null
#
# Indexes
#
#  collation_ext                                                   (collation,category_title,category_type,wikipedia_page_id)
#  from_to                                                         (wikipedia_page_id,category_title)
#  index_wikipedia_category_pages_on_category_title_and_timestamp  (category_title,timestamp)
#  sortkey                                                         (category_title,category_type,sortkey,wikipedia_page_id)
#

require 'test_helper'

class WikipediaCategoryPageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
