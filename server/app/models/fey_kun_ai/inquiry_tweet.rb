# == Schema Information
#
# Table name: fey_kun_ai_inquiry_tweets
#
#  id                :integer          not null, primary key
#  twitter_user_id   :string(255)      not null
#  twitter_user_name :string(255)      not null
#  tweet_id          :string(255)      not null
#  tweet             :string(255)      not null
#  token             :string(255)      not null
#  return_tweet      :string(255)
#  place_name        :string(255)
#  lat               :float(24)
#  lon               :float(24)
#  tweet_quoted_id   :integer
#  tweet_created_at  :datetime         not null
#
# Indexes
#
#  fka_inquiry_lat_lon_index    (lat,lon)
#  fka_inquiry_quoted_id_index  (tweet_quoted_id)
#  fka_inquiry_token_index      (token) UNIQUE
#  fka_inquiry_tweet_id_index   (tweet_id) UNIQUE
#  fka_inquiry_user_id_index    (twitter_user_id)
#  fka_inquiry_user_name_index  (twitter_user_name)
#

class FeyKunAi::InquiryTweet < TwitterRecord

  belongs_to :quoted_source, class_name: 'FeyKunAi::InquiryTweet', foreign_key: :tweet_quoted_id, required: false
  has_many :quoted, class_name: 'FeyKunAi::InquiryTweet', foreign_key: :tweet_quoted_id
  has_many :images, class_name: 'FeyKunAi::InquiryTweetImage', foreign_key: :inquiry_tweet_id

  before_create do
    self.token = SecureRandom.hex
  end

  def self.generate_tweet!(tweet:)
    inquiry_tweet = FeyKunAi::InquiryTweet.find_or_initialize_by(tweet_id: tweet.id)
    transaction do
      if tweet.quoted_tweet?
        quoted_tweet = FeyKunAi::InquiryTweet.find_or_initialize_by(tweet_id: tweet.quoted_tweet.id)
        quoted_tweet.update!(
          twitter_user_id: tweet.quoted_tweet.user.id,
          twitter_user_name: tweet.quoted_tweet.user.screen_name,
          tweet: ApplicationRecord.basic_sanitize(tweet.quoted_tweet.text),
          tweet_created_at: tweet.quoted_tweet.created_at
        )
        quoted_tweet.generate_images!(tweet: tweet.quoted_tweet)
      end
      inquiry_tweet.update!(
        twitter_user_id: tweet.user.id,
        twitter_user_name: tweet.user.screen_name,
        tweet: ApplicationRecord.basic_sanitize(tweet.text),
        tweet_created_at: tweet.created_at,
        tweet_quoted_id: quoted_tweet.try(:id)
      )
      inquiry_tweet.generate_images!(tweet: tweet)
    end
    return inquiry_tweet
  end

  def generate_images!(tweet:)
    image_urls = tweet.media.flat_map do |m|
      case m
      when Twitter::Media::Photo
        m.media_url.to_s
      else
        []
      end
    end
    images = image_urls.map{|url| FeyKunAi::InquiryTweetImage.new(inquiry_tweet_id: self.id, image_url: url, checksum: "") }
    FeyKunAi::InquiryTweetImage.import!(images)
  end
end
