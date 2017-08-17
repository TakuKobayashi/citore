# == Schema Information
#
# Table name: homepage_products
#
#  id              :integer          not null, primary key
#  category        :integer          default("others"), not null
#  title           :string(255)      not null
#  description     :text(65535)
#  thumbnail_url   :string(255)
#  large_image_url :string(255)
#  url             :string(255)
#  pubulish_at     :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_homepage_products_on_pubulish_at  (pubulish_at)
#

class Homepage::Product < ApplicationRecord
  enum category: [
    :others,
    :application,
    :game,
    :web,
    :iot,
    :vrarmr,
    :bot
  ]

  before_create do
    if url.present?
      og = OpenGraph.new(self.url.to_s)
      if self.title.blank?
        self.title = og.title
      end
      if self.description.blank?
        self.description = og.description
      end
      if self.thumbnail_url.blank? && self.large_image_url.blank?
        self_url = Addressable::URI.parse(self.url)
        image_urls = og.images.map do |image_url|
          img_url = Addressable::URI.parse(image_url)
          if img_url.scheme.blank?
            img_url.scheme = self_url.scheme
          end
          if img_url.host.blank?
            img_url.host = self_url.host
          end
          img_url.to_s
        end
        thumbnail_image_url, l_image_url = image_urls.minmax_by do |url|
          size = FastImage.size(url)
          size[0] * size[1]
        end
        self.thumbnail_url = thumbnail_image_url
        self.large_image_url = l_image_url
      end
    end
    if self.pubulish_at.blank?
      self.pubulish_at = Time.current
    end
  end

  after_create do
    announcement = Homepage::Announcement.find_or_initialize_by(from: self)
    announcement.update!(
      title: self.title + "を作成しました",
      description: self.description,
      url: self.url,
      pubulish_at: self.pubulish_at
    )
  end
end
