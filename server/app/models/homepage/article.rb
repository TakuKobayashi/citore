# == Schema Information
#
# Table name: homepage_articles
#
#  id              :bigint(8)        not null, primary key
#  type            :string(255)
#  uid             :string(255)      not null
#  title           :string(255)      not null
#  description     :text(65535)
#  ogp_description :text(65535)
#  url             :string(255)      not null
#  embed_html      :text(65535)
#  thumbnail_url   :string(255)
#  active          :boolean          default(TRUE), not null
#  pubulish_at     :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_homepage_articles_on_pubulish_at  (pubulish_at)
#  index_homepage_articles_on_uid          (uid) UNIQUE
#

class Homepage::Article < ApplicationRecord
  before_create do
    if self.url.present? && self.ogp_description.blank?
      og = OpenGraph.new(self.url.to_s)
      self.ogp_description = og.description
    end
  end

  after_create do
    announcement = Homepage::Announcement.find_or_initialize_by(from: self)
    announcement.update!(
      title: self.title + "を公開しました",
      description: self.title + "を公開しました。",
      url: self.url,
      pubulish_at: self.pubulish_at
    )
  end

  def self.import!
    Homepage::Qiita.import_articles!
    Homepage::Slideshare.import_articles!
  end

  def image_url
    if self.thumbnail_url.blank?
      return "https://png.icons8.com/news/nolan/200"
    else
      return self.thumbnail_url.to_s
    end
  end

  def square_image?
    width, height = FastImage.size(self.image_url)
    # +- 10%の中に入っていれば正方形とみなす
    return width - (width / 10) <= height && height <= width + (width / 10)
  end

  def summary_description
    #og = OpenGraph.new(self.url.to_s)
    #og.description
    text = self.description_text
    plain_text = text.split("\n").map{|t| t.strip.to_s }.join
    if plain_text.size > 140
      return plain_text[0..136].to_s + "..."
    end
    return plain_text.to_s
  end

  def description_text
    doc = Nokogiri::HTML.parse(self.description.to_s)
    return doc.text.to_s.strip
  end
end
