# == Schema Information
#
# Table name: categorised_words
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  large_category  :integer          not null
#  medium_category :string(255)      not null
#  detail_category :string(255)      not null
#  degree          :integer          default("unknown"), not null
#  body            :string(255)      not null
#  from_url        :string(255)
#
# Indexes
#
#  index_categorised_words_on_from_url  (from_url)
#  word_categories_index                (large_category,medium_category,detail_category)
#

class CategorisedWord < ApplicationRecord
  enum large_category: {
    0 => "感情",
    1 => "感覚",
    2 => "人物",
    3 => "風景",
    4 => "食べ物",
  }

  enum degree: [:unknown, :very_low, :low, :normal, :high, :ver_high]
end
