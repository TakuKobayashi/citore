# == Schema Information
#
# Table name: homepage_articles
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  uid         :string(255)      not null
#  title       :string(255)      not null
#  description :text(65535)
#  url         :string(255)      not null
#  embed_html  :text(65535)
#  active      :boolean          default(TRUE), not null
#  pubulish_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_homepage_articles_on_pubulish_at  (pubulish_at)
#  index_homepage_articles_on_uid          (uid) UNIQUE
#

class Homepage::Article < ApplicationRecord
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
end
