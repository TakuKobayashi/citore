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
    tweets = []
    retry_count = 0
    options = {count: 100}
    begin
      tweets = twitter_client.search(keyword, options)
    rescue Twitter::Error::TooManyRequests => e
      Rails.logger.warn "twitter retry since:#{e.rate_limit.reset_in.to_i}"
      retry_count = retry_count + 1
      sleep e.rate_limit.reset_in.to_i
      if retry_count < 5
        retry
      else
        return []
      end
    end
    return generate_images(tweets: tweets, options: {keyword: keyword})
  end

  def self.images_from_user_timeline!(username:)
    tweet_options = {count: TIMELINE_CRAWL_COUNT}
    twitter_client = TwitterRecord.get_twitter_rest_client("citore")
    images = []
    last_tweet_id = nil

    loop do
      if last_tweet_id.present?
        tweet_options[:max_id] = last_tweet_id.to_i
      end
      retry_count = 0
      tweets = []
      begin
        tweets = twitter_client.user_timeline(username, tweet_options)
      rescue Twitter::Error::NotFound => e
        Rails.logger.warn "user not found:" + e.message
      rescue Twitter::Error::NotFound => e
        Rails.logger.warn "twitter retry since:#{e.rate_limit.reset_in.to_i}"
        retry_count = retry_count + 1
        sleep e.rate_limit.reset_in.to_i
        if retry_count < 5
          retry
        end
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
    twitter_images = Datapool::ImageMetum.find_origin_src_by_url(url: tweets.map{|t| TwitterRecord.get_image_urls_from_tweet(tweet: t) }).index_by(&:src)
    twitter_videos = Datapool::VideoMetum.find_origin_src_by_url(url: tweets.map{|t| TwitterRecord.get_video_urls_from_tweet(tweet: t) }).index_by(&:src)
    twitter_websites = Datapool::Website.find_origin_src_by_url(url: tweets.map{|t| t.urls.flat_map{|urle| urle.expanded_url.to_s } }).index_by(&:src)
    videos = []
    websites = []
    quoteds_tweets = []

    tweets.each do |tweet|
      image_urls = TwitterRecord.get_image_urls_from_tweet(tweet: tweet)
      image_urls.each do |image_url|
        if twitter_images[image_url].present?
          images << twitter_images[image_url]
        else
          images << self.constract_image_from_tweet(tweet: tweet, image_url: image_url, options: options)
        end
      end

      videos += Datapool::TwitterVideoMetum.constract_from_tweet(tweet: tweet)
      websites += Datapool::TwitterWebsite.constract_from_tweet(tweet: tweet)
      if tweet.quoted_tweet?
        quoteds_tweets << tweet.quoted_tweet
      end
    end
    images.uniq!(&:src)
    self.import_resources!(resources: images + videos + websites)
    if quoteds_tweets.present?
      images += self.generate_images(tweets: quoteds_tweets, options: options)
    end
    return images
  end

  def self.constract_image_from_tweet(tweet:, image_url:, options: {})
    tweet_text = Sanitizer.basic_sanitize(tweet.text)
    tweet_text = Sanitizer.delete_urls(tweet_text)
    image = self.constract(
      url: image_url.to_s,
      title: tweet_text,
      check_file: false,
      options: {
        tweet_id: tweet.id
      }.merge(options)
    )
    return image
  end
end
