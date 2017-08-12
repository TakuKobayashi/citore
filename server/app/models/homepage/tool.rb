# == Schema Information
#
# Table name: homepage_tools
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :text(65535)
#  path        :string(255)
#  pubulish_at :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_homepage_tools_on_pubulish_at  (pubulish_at)
#

class Homepage::Tool < ApplicationRecord
  after_create do
    announcement = Homepage::Announcement.find_or_initialize_by(from: self)
    announcement.update!(
      title: self.title + "を作成しました",
      description: self.description,
      url: self.path,
      pubulish_at: self.pubulish_at
    )
  end
end
