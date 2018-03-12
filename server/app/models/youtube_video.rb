# == Schema Information
#
# Table name: youtube_videos
#
#  id                  :integer          not null, primary key
#  video_id            :string(255)      default(""), not null
#  youtube_channel_id  :integer
#  youtube_category_id :integer
#  title               :string(255)      default(""), not null
#  description         :text(65535)
#  thumnail_image_url  :string(255)      default(""), not null
#  published_at        :datetime
#  dislike_count       :integer          default(0), not null
#  like_count          :integer          default(0), not null
#  favorite_count      :integer          default(0), not null
#  view_count          :integer          default(0), not null
#  comment_count       :integer          default(0), not null
#
# Indexes
#
#  index_youtube_videos_on_comment_count       (comment_count)
#  index_youtube_videos_on_published_at        (published_at)
#  index_youtube_videos_on_video_id            (video_id) UNIQUE
#  index_youtube_videos_on_youtube_channel_id  (youtube_channel_id)
#

class YoutubeVideo < YoutubeRecord
  #belongs_to :channel, class_name: 'YoutubeChannel', foreign_key: :youtube_channel_id
  has_many :comments, class_name: 'YoutubeComment', foreign_key: :youtube_video_id
  has_many :tags, class_name: 'YoutubeComment', foreign_key: :youtube_video_id

  def video_url
    url = Addressable::URI.parse("https://www.youtube.com/watch")
    url.query_values = {v: self.video_id}
    return url.to_s
  end

  def self.import_video!(youtube_video, category_id: nil, channel_id: nil)
    videos = []
    id_and_tags = {}
    youtube_video.items.each do |item|
      video = YoutubeVideo.new(
        youtube_category_id: category_id,
        youtube_channel_id: channel_id,
        video_id: item.id,
        title: Sanitizer.basic_sanitize(item.snippet.title),
        description: Sanitizer.basic_sanitize(item.snippet.description),
        published_at: item.snippet.published_at,
        thumnail_image_url: item.snippet.thumbnails.default.url,
        comment_count: item.statistics.try(:comment_count).to_i,
        dislike_count: item.statistics.try(:dislike_count).to_i,
        like_count: item.statistics.try(:like_count).to_i,
        favorite_count: item.statistics.try(:favorite_count).to_i,
        view_count: item.statistics.try(:view_count).to_i
      )
      id_and_tags[item.id] = item.snippet.tags
      videos << video
    end
    updates = [:published_at]
    updates << :youtube_channel_id if channel_id.present?
    updates <<  :youtube_category_id if category_id.present?
    YoutubeVideo.import(videos, on_duplicate_key_update: updates)
    YoutubeVideo.import_tags(id_and_tags)
  end

  def self.import_tags(video_id_and_tags)
    video_ids = YoutubeVideo.where(video_id: video_id_and_tags.keys).pluck(:id, :video_id)
    tags = video_ids.map do |id, video_id|
      if video_id_and_tags[video_id].blank?
        nil
      else
        results = []
        video_id_and_tags[video_id].each do |tag|
          sanitized = Sanitizer.basic_sanitize(tag)
          next if sanitized.blank?
          sanitize_split_tags = [sanitized]
          if sanitized.length > 255
            sanitize_split_tags = sanitized.split(" ")
          end
          results += sanitize_split_tags.map do |t|
            YoutubeVideoTag.new(youtube_video_id: id, tag: t)
          end
        end
        results
      end
    end.flatten.compact
    YoutubeVideoTag.import(tags, on_duplicate_key_update: [:youtube_video_id, :tag])
  end

  def import_related_video!(youtube_video)
    YoutubeVideo.import_video!(youtube_video)
    video_ids = YoutubeVideo.where(video_id: youtube_video.items.map(&:id)).pluck(:id)
    relateds = video_ids.map do |to_id|
      YoutubeVideoRelated.new(youtube_video_id: self.id, to_youtube_video_id: to_id)
    end
    YoutubeVideoRelated.import(relateds)
  end
end
