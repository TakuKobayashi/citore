# == Schema Information
#
# Table name: crawl_target_urls
#
#  id                                 :integer          not null, primary key
#  source_type                        :string(255)      not null
#  crawl_from_keyword                 :string(255)
#  protocol                           :string(255)      not null
#  host                               :string(255)      not null
#  port                               :integer
#  path                               :string(255)      default(""), not null
#  query                              :text(65535)      not null
#  crawled_at                         :datetime
#  content_type                       :string(255)
#  status_code                        :integer
#  message                            :string(255)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  source_id                          :integer
#  title                              :string(255)      default(""), not null
#  target_class_column_extension_json :text(65535)
#
# Indexes
#
#  index_crawl_target_urls_on_crawl_from_keyword          (crawl_from_keyword)
#  index_crawl_target_urls_on_crawled_at_and_status_code  (crawled_at,status_code)
#  index_crawl_target_urls_on_host_and_path               (host,path)
#  index_crawl_target_urls_on_source_type_and_source_id   (source_type,source_id)
#

require 'test_helper'

class CrawlTargetUrlTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
