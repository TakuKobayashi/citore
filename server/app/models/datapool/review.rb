# == Schema Information
#
# Table name: datapool_reviews
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  title       :string(255)      not null
#  score       :float(24)        default(0.0), not null
#  message     :text(65535)      not null
#  product_id  :string(255)      not null
#  user_name   :string(255)
#  product_url :string(255)      not null
#  options     :text(65535)
#
# Indexes
#
#  reviews_product_url_index     (product_url)
#  reviews_unique_product_index  (product_id,type)
#

class Datapool::Review < ApplicationRecord
  serialize :options, JSON
end
