# == Schema Information
#
# Table name: crawl_target_urls
#
#  id                 :integer          not null, primary key
#  source_type        :string(255)      not null
#  crawl_from_keyword :string(255)
#  protocol           :string(255)      not null
#  host               :string(255)      not null
#  port               :integer
#  path               :string(255)      default(""), not null
#  query              :text(65535)      not null
#  crawled_at         :datetime
#  content_type       :string(255)
#  status_code        :integer
#  message            :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  source_id          :integer
#
# Indexes
#
#  index_crawl_target_urls_on_crawl_from_keyword          (crawl_from_keyword)
#  index_crawl_target_urls_on_crawled_at_and_status_code  (crawled_at,status_code)
#  index_crawl_target_urls_on_host_and_path               (host,path)
#  index_crawl_target_urls_on_source_type_and_source_id   (source_type,source_id)
#

class CrawlTargetUrl < ApplicationRecord
  def self.setting_target!(target_class_name, url_string, from_keyword)
    url = Addressable::URI.parse(url_string)
    return CrawlTargetUrl.create!({
      source_type: target_class_name,
      crawl_from_keyword: from_keyword,
      protocol: url.scheme,
      host: url.host,
      path: url.path,
      query: url.query.to_s
    })
  end

  def self.execute_html_crawl!(&block)
    CrawlTargetUrl.where(source_type: Lyric.to_s, crawled_at: nil).find_each do |crawl_target|
      url = Addressable::URI.new({host: crawl_target.host,port: crawl_target.port,path: crawl_target.path})
      url.scheme = crawl_target.protocol
      url.query = crawl_target.query
      http_client = HTTPClient.new
      response = http_client.get(url.to_s, {}, {})
      next if response.status.to_i >= 400
      crawl_target.status_code = response.status
      crawl_target.content_type = response.headers["Content-Type"]
      doc = Nokogiri::HTML.parse(response.body)
      transaction do
        block.call(crawl_target, doc)
        crawl_target.crawled_at = Time.now
        crawl_target.save!
      end
    end
  end
end
