# == Schema Information
#
# Table name: wikipedia_topic_categories
#
#  id      :integer          not null, primary key
#  title   :string(255)      default(""), not null
#  pages   :integer          default(0), not null
#  subcats :integer          default(0), not null
#  files   :integer          default(0), not null
#
# Indexes
#
#  index_wikipedia_topic_categories_on_pages  (pages)
#  index_wikipedia_topic_categories_on_title  (title) UNIQUE
#

require 'test_helper'

class WikipediaTopicCategoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
