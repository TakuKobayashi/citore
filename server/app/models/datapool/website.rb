# == Schema Information
#
# Table name: datapool_websites
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  title      :string(255)      not null
#  origin_src :string(255)      not null
#  query      :text(65535)
#  options    :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_origin_src  (origin_src)
#  index_datapool_websites_on_title       (title)
#

class Datapool::Website < Datapool::ResourceMetum
  serialize :options, JSON

  def self.constract(url:, title: "", options: {})
    website = self.new(
      title: title,
      options: {
      }.merge(options)
    )
    website.src = url
    return website
  end

  def self.resource_crawl!
    Datapool::Website.find_each do |website|
      next if website.options["image_crawled_at"].present?
      Datapool::WebSiteImageMetum.crawl_images!(url: website.src)
      website.options["image_crawled_at"] = Time.current
      site = ApplicationRecord.request_and_parse_html(website.src)
      if site.title.present?
        website.title = site.title
      end
      website.save!
    end
  end
end
