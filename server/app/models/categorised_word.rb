# == Schema Information
#
# Table name: categorised_words
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  large_category  :integer          default("large_unknown"), not null
#  medium_category :string(255)      default(""), not null
#  detail_category :string(255)      not null
#  body            :text(65535)      not null
#  description     :text(65535)
#
# Indexes
#
#  word_categories_index  (large_category,medium_category,detail_category)
#

class CategorisedWord < ApplicationRecord
  enum large_category: {
    large_unknown: 0,
    feeling: 1,
    sense: 2,
    person: 3,
    living: 4,
    landscape: 5,
    food: 6,
    greeting: 7,
    behavior: 8,
  }
end
