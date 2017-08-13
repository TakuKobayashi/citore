# == Schema Information
#
# Table name: homepage_likes
#
#  id                 :integer          not null, primary key
#  from_type          :string(255)      not null
#  from_id            :integer          not null
#  homepage_access_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  homepage_likes_primary_index                (from_type,from_id,homepage_access_id) UNIQUE
#  index_homepage_likes_on_homepage_access_id  (homepage_access_id)
#

class Homepage::Like < ApplicationRecord
  belongs_to :from, polymorphic: true, required: false
  belongs_to :visitor, class_name: 'Homepage::Access', foreign_key: :homepage_access_id, required: false
end
