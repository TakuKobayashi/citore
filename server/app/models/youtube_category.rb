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

class YoutubeCategory < YoutubeRecord
  enum kind: { video: 0, guide: 1}

  def self.generate_categories
    crawl_loop_request do |youtube, page_token|
      video_category_list = youtube.list_video_categories("id,snippet", region_code: "JP", hl: "ja_JP")
      transaction do
        video_category_list.items.each do |item|
          video_cat = YoutubeCategory.find_or_initialize_by(kind: 0, category_id: item.id)
          video_cat.update!(title: item.snippet.title, channel_id: item.snippet.channel_id)
        end
      end
      video_category_list
    end
    crawl_loop_request do |youtube, page_token|
      guide_category_list = youtube.list_guide_categories("id,snippet", region_code: "JP", hl: "ja_JP")
      transaction do
        guide_category_list.items.each do |item|
          guide_cat = YoutubeCategory.find_or_initialize_by(kind: 1, category_id: item.id)
          guide_cat.update!(title: item.snippet.title, channel_id: item.snippet.channel_id)
        end
      end
      guide_category_list
    end
  end
end
