# == Schema Information
#
# Table name: homepage_accesses
#
#  id         :integer          not null, primary key
#  ip_address :string(255)      not null
#  uid        :string(255)      not null
#  user_agent :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_homepage_accesses_on_ip_address  (ip_address)
#  index_homepage_accesses_on_uid         (uid) UNIQUE
#

require 'test_helper'

class Homepage::AccessTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
