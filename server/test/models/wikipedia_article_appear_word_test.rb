# == Schema Information
#
# Table name: wikipedia_article_appear_words
#
#  id                   :integer          not null, primary key
#  wikipedia_article_id :integer          not null
#  appear_word_id       :integer          not null
#  category             :integer          not null
#
# Indexes
#
#  article_appear_words_index  (wikipedia_article_id,appear_word_id,category)
#

require 'test_helper'

class WikipediaArticleAppearWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
