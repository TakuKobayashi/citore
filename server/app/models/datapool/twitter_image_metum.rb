# == Schema Information
#
# Table name: datapool_image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  query             :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_image_meta_on_origin_src  (origin_src)
#  index_datapool_image_meta_on_title       (title)
#

class Datapool::TwitterImageMetum < Datapool::ImageMetum
  TIMELINE_CRAWL_COUNT = 200

  def self.search_image_tweet!(keyword:)
    twitter_client = TwitterRecord.get_twitter_rest_client("citore")
    tweets = twitter_client.search(keyword)
    return generate_images(tweets: tweets, options: {keyword: keyword})
  end

  def self.images_from_user_timeline!(username:)
    tweet_options = {count: TIMELINE_CRAWL_COUNT}
    twitter_client = TwitterRecord.get_twitter_rest_client("citore")
    images = []
    last_tweet_id = nil

    loop do
      if last_tweet_id.present?
        options[:max_id] = last_tweet_id.to_i
      end
      begin
        tweets = twitter_client.user_timeline(username, options)
      rescue Twitter::Error::NotFound => e
        Rails.logger.warn "user not found:" + e.message
      end
      images += generate_images(tweets: tweets, options: {username: username})
      break if tweets.size < TIMELINE_CRAWL_COUNT
      last_tweet_id = tweets.select{|s| s.try(:id).present? }.min_by{|s| s.id.to_i }.try(:id).to_i
    end
    return images
  end

  private
  def self.generate_images(tweets:, options: {})
    images = []
    tweets.each do |tweet|
      image_urls = TwitterRecord.get_image_urls_from_tweet(tweet: tweet)
      if image_urls.present?
        images += self.constract_images_from_tweet(tweet: tweet, image_urls: image_urls, options: options)
      end
      if tweet.quoted_tweet? && tweet.quoted_tweet.media.present?
        qimage_urls = TwitterRecord.get_image_urls_from_tweet(tweet: tweet.quoted_tweet)
        if qimage_urls.present?
          images += self.constract_images_from_tweet(tweet: tweet.quoted_tweet, image_urls: qimage_urls, options: options)
        end
      end
    end
    self.import!(images)
    return images
  end

  def self.constract_images_from_tweet(tweet:, image_urls:, options: {})
    tweet_text = ApplicationRecord.basic_sanitize(tweet.text)
    tweet_text = ApplicationRecord.separate_urls(tweet_text).first
    images = []
    image_urls.each do |image_url|
      image = self.constract(
        image_url: image_url.to_s,
        title: tweet_text,
        options: {
          tweet_id: tweet.id
        }.merge(options)
      )
      images << image
    end
    return images
  end
end
