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

  after_validation :geocode
  after_validation :reverse_geocode

  geocoded_by :place_name, latitude: :lat, longitude: :lon
  reverse_geocoded_by :lat, :lon, address: :place_name, language: :ja

  before_create do
    self.token = SecureRandom.hex
  end

  before_save do
    self.place_name = Charwidth.normalize(self.place_name.to_s)
  end

  def self.generate_tweet!(tweet:)
    inquiry_tweet = FeyKunAi::InquiryTweet.find_or_initialize_by(tweet_id: tweet.id)
    transaction do
      inquiry_tweet.update!({
        twitter_user_id: tweet.user.id,
        twitter_user_name: tweet.user.screen_name,
        tweet: Sanitizer.basic_sanitize(tweet.text),
        tweet_created_at: tweet.created_at
      }.merge(self.extract_location_hash(tweet: tweet)))
      inquiry_tweet.generate_images!(tweet: tweet, reply_to_tweet: inquiry_tweet)
      if tweet.quoted_tweet?
        quoted_tweet_status = tweet.quoted_tweet
        quoted_tweet = FeyKunAi::InquiryTweet.find_or_initialize_by(tweet_id: quoted_tweet_status.id)
        quoted_tweet.update!({
          twitter_user_id: quoted_tweet_status.user.id,
          twitter_user_name: quoted_tweet_status.user.screen_name,
          tweet: Sanitizer.basic_sanitize(quoted_tweet_status.text),
          tweet_created_at: quoted_tweet_status.created_at
        }.merge(self.extract_location_hash(tweet: quoted_tweet_status)))
        quoted_tweet.generate_images!(tweet: quoted_tweet_status, reply_to_tweet: inquiry_tweet)
      end
      inquiry_tweet.update!(tweet_quoted_id: quoted_tweet.try(:id))
    end
    return inquiry_tweet
  end

  def self.extract_location_hash(tweet:)
    result = {}
    if tweet.place?
      lonlats = tweet.place.bounding_box.coordinates.flatten
      lonlats.each_with_index do |lonlat, index|
        if index % 2 == 0
          result[:lon] = result[:lon].to_f + lonlat
        else
          result[:lat] = result[:lat].to_f + lonlat
        end
      end
      result[:place_name] = tweet.place.full_name
      result[:lon] = result[:lon].to_f / (lonlats.size / 2).to_f
      result[:lat] = result[:lat].to_f / (lonlats.size / 2).to_f
    end
    if tweet.geo?
      latlons = tweet.geo.coordinates.flatten
      latlons.each_with_index do |latlon, index|
        if index % 2 == 0
          result[:lat] = result[:lat].to_f + latlon
        else
          result[:lon] = result[:lon].to_f + latlon
        end
      end
      result[:lat] = result[:lat].to_f / (latlons.size / 2).to_f
      result[:lon] = result[:lon].to_f / (latlons.size / 2).to_f
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
    image_urls = TwitterRecord.get_image_urls_from_tweet(tweet: tweet)
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
