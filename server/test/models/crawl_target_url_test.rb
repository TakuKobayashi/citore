# == Schema Information
#
# Table name: crawl_target_urls
#
#  id          :integer          not null, primary key
#  source_type :string(255)      not null
#  protocol    :string(255)      not null
#  method      :string(255)      not null
#  host        :string(255)      not null
#  path        :string(255)      not null
#  params      :text(65535)      not null
#  crawled_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_crawl_target_urls_on_crawled_at     (crawled_at)
#  index_crawl_target_urls_on_host_and_path  (host,path)
#  index_crawl_target_urls_on_source_type    (source_type)
#

require 'test_helper'

class CrawlTargetUrlTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
