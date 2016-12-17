# == Schema Information
#
# Table name: crawl_target_urls
#
#  id           :integer          not null, primary key
#  source_type  :string(255)      not null
#  protocol     :string(255)      not null
#  method       :string(255)      not null
#  host         :string(255)      not null
#  path         :string(255)      not null
#  query        :text(65535)      not null
#  crawled_at   :datetime
#  content_type :string(255)
#  status_code  :integer
#  message      :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_crawl_target_urls_on_crawled_at_and_status_code  (crawled_at,status_code)
#  index_crawl_target_urls_on_host_and_path               (host,path)
#

class CrawlTargetUrl < ApplicationRecord
  def self.setting_target!(target_class_name, url_string)
    url = Addressable::URI.parse(url_string)
    return CrawlTargetUrl.create!({
      source_type: target_class_name,
      protocol: url.scheme,
      host: url.host,
      path: url.path,
      query: url.query.to_s
    })
  end
end
