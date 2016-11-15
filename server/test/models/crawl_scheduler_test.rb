# == Schema Information
#
# Table name: crawl_schedulers
#
#  id             :integer          not null, primary key
#  state          :integer          default(0), not null
#  search_kind    :integer          default(0), not null
#  search_word    :string(255)      not null
#  resource_type  :string(255)
#  resource_id    :integer
#  start_time     :datetime
#  completed_time :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class CrawlSchedulerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
