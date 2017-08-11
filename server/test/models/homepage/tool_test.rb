# == Schema Information
#
# Table name: homepage_tools
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text(65535)
#  path        :string(255)
#  pubulish_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_homepage_tools_on_pubulish_at  (pubulish_at)
#

require 'test_helper'

class Homepage::ToolTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
