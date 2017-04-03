# == Schema Information
#
# Table name: homepage_announcements
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  html_body   :text(65535)      not null
#  url         :string(255)
#  pubulish_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_homepage_announcements_on_pubulish_at  (pubulish_at)
#

require 'test_helper'

class Homepage::AnnouncementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
