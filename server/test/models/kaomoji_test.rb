# == Schema Information
#
# Table name: kaomojis
#
#  id       :integer          not null, primary key
#  category :string(255)      not null
#  meaning  :string(255)      not null
#  body     :string(255)      not null
#  from     :string(255)
#
# Indexes
#
#  index_kaomojis_on_category  (category)
#  index_kaomojis_on_meaning   (meaning)
#

require 'test_helper'

class KaomojiTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
