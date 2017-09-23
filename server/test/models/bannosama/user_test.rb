# == Schema Information
#
# Table name: bannosama_users
#
#  id                 :integer          not null, primary key
#  type               :string(255)
#  name               :string(255)
#  thumnail_image_url :string(255)
#  uuid               :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_bannosama_users_on_uuid  (uuid) UNIQUE
#

require 'test_helper'

class Bannosama::UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
