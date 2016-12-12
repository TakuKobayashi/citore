# == Schema Information
#
# Table name: wikipedia_themes
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  crawled_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_wikipedia_themes_on_crawled_at  (crawled_at)
#

require 'test_helper'

class WikipediaThemeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
