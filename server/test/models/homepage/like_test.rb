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

require 'test_helper'

class Homepage::LikeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
