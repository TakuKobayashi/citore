# == Schema Information
#
# Table name: youtube_categories
#
#  id          :integer          not null, primary key
#  category_id :string(255)      default(""), not null
#  kind        :integer          not null
#  channel_id  :string(255)      default(""), not null
#  title       :string(255)      default(""), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_youtube_categories_on_title  (title)
#

class YoutubeCategory < ApplicationRecord
  enum kind: { video: 0, guide: 1}
end
