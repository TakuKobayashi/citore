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

class WikipediaArticleAppearWord < ApplicationRecord
  enum category: [:title, :article]

  belongs_to :appear_word
  belongs_to :wikipedia_article
end
