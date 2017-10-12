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
      options[:until] = 1.day.ago.strftime("%Y-%m-%d")
      if retry_count < 5
        retry
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
    all_image_urls = tweets.flat_map do |tweet|
      image_urls = TwitterRecord.get_image_urls_from_tweet(tweet: tweet)
      if tweet.quoted_tweet?
        image_urls += TwitterRecord.get_image_urls_from_tweet(tweet: tweet.quoted_tweet)
      end
      image_urls
    end.uniq
    twitter_images = Datapool::TwitterImageMetum.where(origin_src: all_image_urls).index_by(&:origin_src)
    import_videos = []
    all_image_urls = []

    tweets.each do |tweet|
      is_depulicate = false
      image_urls = TwitterRecord.get_image_urls_from_tweet(tweet: tweet)
      image_urls.each do |image_url|
        if all_image_urls.include?(image_url)
          is_depulicate = true
          next
        end
        all_image_urls << image_url
        if twitter_images[image_url].present?
          images << twitter_images[image_url]
          is_depulicate = true
        else
          images << self.constract_image_from_tweet(tweet: tweet, image_url: image_url, options: options)
        end
      end
      if !is_depulicate
        import_videos += Datapool::TwitterVideoMetum.constract_from_tweet(tweet: tweet)
      end
      if tweet.quoted_tweet? && tweet.quoted_tweet.media.present?
        is_qdepulicate = false
        qimage_urls = TwitterRecord.get_image_urls_from_tweet(tweet: tweet.quoted_tweet)
        qimage_urls.each do |image_url|
          if all_image_urls.include?(image_url)
            is_qdepulicate = true
            next
          end
          all_image_urls << image_url
          if twitter_images[image_url].present?
            images << twitter_images[image_url]
            is_qdepulicate = true
          else
            images << self.constract_image_from_tweet(tweet: tweet.quoted_tweet, image_url: image_url, options: options)
          end
        end
        if !is_qdepulicate
          import_videos += Datapool::TwitterVideoMetum.constract_from_tweet(tweet: tweet.quoted_tweet)
        end
      end
    end
    self.import!(images.select(&:new_record?))
    Datapool::TwitterVideoMetum.import!(import_videos.flatten)
    return images
  end

  def self.constract_image_from_tweet(tweet:, image_url:, options: {})
    tweet_text = ApplicationRecord.basic_sanitize(tweet.text)
    tweet_text = ApplicationRecord.separate_urls(tweet_text).first
    image = self.constract(
      image_url: image_url.to_s,
      title: tweet_text,
      options: {
        tweet_id: tweet.id
      }.merge(options)
    )
    return image
  end
end
