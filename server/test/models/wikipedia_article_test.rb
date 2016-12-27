# == Schema Information
#
# Table name: wikipedia_articles
#
#  id                :integer          not null, primary key
#  wikipedia_page_id :integer          default(0), not null
#  title             :string(255)      default(""), not null
#  body              :text(4294967295)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_wikipedia_articles_on_title              (title)
#  index_wikipedia_articles_on_wikipedia_page_id  (wikipedia_page_id)
#

require 'test_helper'

class WikipediaArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
