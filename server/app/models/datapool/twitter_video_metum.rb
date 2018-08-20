# == Schema Information
#
# Table name: datapool_video_meta
#
#  id              :bigint(8)        not null, primary key
#  type            :string(255)
#  title           :string(255)      not null
#  front_image_url :text(65535)
#  data_category   :integer          default("file"), not null
#  bitrate         :integer          default(0), not null
#  origin_src      :string(255)      not null
#  other_src       :text(65535)
#  options         :text(65535)
#
# Indexes
#
#  index_datapool_video_meta_on_origin_src  (origin_src)
#  index_datapool_video_meta_on_title       (title)
#

class Datapool::TwitterVideoMetum < Datapool::VideoMetum
  def self.constract_from_tweet(tweet:)
    return [] unless tweet.media?
    tweet_text = Sanitizer.basic_sanitize(tweet.text)
    tweet_text = Sanitizer.delete_urls(tweet_text)

    videos = tweet.media.flat_map do |m|
      case m
      when Twitter::Media::Video
        max_bitrate_variant = m.video_info.variants.max_by{|variant| variant.bitrate.to_i }
        video = Datapool::TwitterVideoMetum.new(
          title: tweet_text,
          front_image_url: m.media_url.to_s,
          data_category: :file,
          bitrate: max_bitrate_variant.try(:bitrate),
          options: {duration: m.video_info.duration_millis}
        )
        video.src = max_bitrate_variant.try(:url).to_s
        video
      else
        []
      end
    end
    return videos
  end
end
