# == Schema Information
#
# Table name: homepage_announcements
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  from_type   :string(255)
#  from_id     :integer
#  description :text(65535)
#  url         :string(255)
#  pubulish_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_homepage_announcements_on_from_type_and_from_id  (from_type,from_id)
#  index_homepage_announcements_on_pubulish_at            (pubulish_at)
#

require 'test_helper'

class Homepage::AnnouncementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
