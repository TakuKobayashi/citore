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

class CrawlTargetUrl < ApplicationRecord
  serialize :target_class_column_extension_json, JSON
  #belongs_to :source, polymorphic: true

  def self.setting_target!(target_class_name:, url:, from_url:, column_extension: {}, title: "")
    aurl = Addressable::URI.parse(url)
    return CrawlTargetUrl.create!({
      source_type: target_class_name,
      path: aurl.path,
      title: title.to_s,
      crawl_from_keyword: from_url,
      protocol: aurl.scheme.to_s,
      host: aurl.host,
      path: aurl.path.to_s,
      query: aurl.query.to_s,
      target_class_column_extension_json: column_extension,
    })
  end

  def target_url
    url = Addressable::URI.new({host: self.host,port: self.port,path: self.path})
    url.scheme = self.protocol
    url.query = self.query
    return url.to_s
  end

  def self.execute_html_crawl!(clazz)
    CrawlTargetUrl.where(source_type: clazz.to_s, crawled_at: nil).find_each do |crawl_target|
      begin
        http_client = HTTPClient.new
        response = http_client.send(crawl_target.request_method_category, crawl_target.target_url, {}, {})
        next if response.status.to_i >= 400
        crawl_target.status_code = response.status
        crawl_target.content_type = response.headers["Content-Type"]
        doc = Nokogiri::HTML.parse(response.body)
        transaction do
          yield(crawl_target, doc)
          crawl_target.crawled_at = Time.now
          crawl_target.save!
        end
      rescue
        sleep 1
      end
    end
  end

  def self.import_crawl_data!(html_dom:,target_class:,column_dom:, request_method: :get)
    clazz = target_class.to_s.constantize
    columns_h = clazz.columns_hash
    d_enums = clazz.defined_enums
    clazz_instance = clazz.new
    column_dom.each do |key, dom|
      if d_enums[key].present?
        clazz_instance.send(key + "=", dom)
        next
      end
      if dom.present?
        crawl_text = html_dom.css(dom).text
      else
        crawl_text = html_dom.text
      end

      if columns_h[key].type.to_s == "integer" || columns_h[key].type.to_s == "float"
        clazz_instance.send(key + "=", dom)
      elsif columns_h[key].type.to_s == "string" || columns_h[key].type.to_s == "text"
        clazz_instance.send(key + "=", ApplicationRecord.basic_sanitize(crawl_text))
      end
    end
    clazz_instance.save!
  end
end
