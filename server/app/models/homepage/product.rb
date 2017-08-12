# == Schema Information
#
# Table name: homepage_products
#
#  id              :integer          not null, primary key
#  category        :integer          default(0), not null
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
