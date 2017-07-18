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
  has_many :quoted_tweets, class_name: 'FeyKunAi::InquiryTweet', foreign_key: :tweet_quoted_id
  has_many :images, class_name: 'FeyKunAi::InquiryTweetImage', foreign_key: :inquiry_tweet_id

  geocoded_by :place_name, latitude: :lat, longitude: :lon
  reverse_geocoded_by :place_name, latitude: :lat, longitude: :lon

  after_validation :geocode
  after_validation :reverse_geocode

  before_create do
    self.place_name = Charwidth.normalize(self.place_name)
    self.token = SecureRandom.hex
  end

  def self.generate_tweet!(tweet:)
    inquiry_tweet = FeyKunAi::InquiryTweet.find_or_initialize_by(tweet_id: tweet.id)
    transaction do
      inquiry_tweet.update!({
        twitter_user_id: tweet.user.id,
        twitter_user_name: tweet.user.screen_name,
        tweet: ApplicationRecord.basic_sanitize(tweet.text),
        tweet_created_at: tweet.created_at
      }.merge(self.extract_location_hash(tweet: tweet)))
      inquiry_tweet.generate_images!(tweet: tweet, reply_to_tweet: inquiry_tweet.id)
      if tweet.quoted_tweet?
        quoted_tweet_status = tweet.quoted_tweet
        quoted_tweet = FeyKunAi::InquiryTweet.find_or_initialize_by(tweet_id: quoted_tweet_status.id)
        quoted_tweet.update!({
          twitter_user_id: quoted_tweet_status.user.id,
          twitter_user_name: quoted_tweet_status.user.screen_name,
          tweet: ApplicationRecord.basic_sanitize(quoted_tweet_status.text),
          tweet_created_at: quoted_tweet_status.created_at
        }.merge(self.extract_location_hash(tweet: quoted_tweet_status)))
        quoted_tweet.generate_images!(tweet: quoted_tweet_status, reply_to_tweet: inquiry_tweet.id)
      end
      inquiry_tweet.update!(tweet_quoted_id: quoted_tweet.try(:id))
    end
    return inquiry_tweet
  end

  def self.extract_location_hash(tweet:)
    result = {}
    if tweet.place?
      lonlat_sum = tweet.place.bounding_box.coordinates.inject([0, 0]){|result, lonlat| result[0] += lonlat[0]; result[1] += lonlat[1]; }
      result[:place_name] = tweet.place.full_name
      result[:lat] = lonlat_sum[1] / lonlat_sum.size.to_f
      result[:lon] = lonlat_sum[0] / lonlat_sum.size.to_f
    end
    if tweet.geo?
      latlon_sum = tweet.geo.coordinates.inject([0, 0]){|result, latlon| result[0] += latlon[0]; result[1] += latlon[1]; }
      result[:lat] = latlon_sum[0] / latlon_sum.size.to_f
      result[:lon] = latlon_sum[1] / latlon_sum.size.to_f
    end
    if result.blank?
      arr = []
      natto = Natto::MeCab.new
      natto.parse(tweet.text) do |n|
        if n.feature.split(",")[2] == "地域"
          arr << n.surface
        end
      end
      result[:place_name] = arr.join
    end
    return result
  end

  def generate_images!(tweet:, reply_to_tweet:)
    image_urls = FeyKunAi::InquiryTweetImage.get_image_urls_from_tweet(tweet: tweet)
    images = image_urls.map do |url|
      image = FeyKunAi::InquiryTweetImage.new(inquiry_tweet_id: self.id, image_url: url, reply_to_tweet_id: reply_to_tweet.id)
      image.set_image_meta_data
      image
    end
    FeyKunAi::InquiryTweetImage.import!(images)
  end

  def check_and_request_analize
    standby_images = self.images.standby
    standby_images.each do |image|
      FeyKunJob.perform_later(image)
    end
    if self.quoted_source.present?
      quoted_standby_images = self.quoted_source.images.standby
      quoted_standby_images.each do |quoted_image|
        FeyKunJob.perform_later(quoted_image)
      end
    end
  end
end
