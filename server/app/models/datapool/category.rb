# == Schema Information
#
# Table name: datapool_categories
#
#  id                 :bigint(8)        not null, primary key
#  name               :string(255)      not null
#  defined_number     :integer          default("unknown"), not null
#  parent_category_id :integer
#
# Indexes
#
#  index_datapool_categories_on_defined_number      (defined_number)
#  index_datapool_categories_on_name                (name) UNIQUE
#  index_datapool_categories_on_parent_category_id  (parent_category_id)
#

class Datapool::Category < ApplicationRecord
  enum defined_number: {
    unknown: 0,
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
