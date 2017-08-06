# == Schema Information
#
# Table name: food_forecast_user_weather_locations
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  lat             :float(24)
#  lon             :float(24)
#  ip_address      :string(255)      not null
#  address         :string(255)
#  accessed_at     :datetime         not null
#  weather_reports :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  user_weather_locations_accessed_at_index  (accessed_at)
#  user_weather_locations_ip_address_index   (ip_address)
#  user_weather_locations_lat_lon_index      (lat,lon)
#  user_weather_locations_user_id_index      (user_id)
#

class FoodForecast::UserWeatherLocation < ApplicationRecord
  serialize :weather_reports, JSON
  has_many :restaurant_outputs, class_name: 'FoodForecast::UserRestaurantOutput', foreign_key: :user_location_id

  #http://webservice.recruit.co.jp/hotpepper/reference.html
  HOTPEPPER_API_URL = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/"

  #http://api.gnavi.co.jp/api/manual/restsearch/
  GNAVI_API_URL = "https://api.gnavi.co.jp/RestSearchAPI/20150630/"

  #https://developers.google.com/places/web-service/search?hl=ja
  GOOGLE_PLACE_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters"

  YAHOO_WEATHER_API_URL = "https://map.yahooapis.jp/weather/V1/place"

  after_validation :reverse_geocode
  reverse_geocoded_by :lat, :lon, address: :address, language: :ja

  def update_weather_reports!
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = HTTPClient.new
    response = client.get(YAHOO_WEATHER_API_URL, {appid: apiconfig["yahoo"]["appId"], coordinates: [self.lat, self.lon].join(","), output: :json})
    hash = JSON.parse(response.body)
    update!(weather_reports: hash["Feature"])
  end

  def self.icon_url
    return "https://s3-ap-northeast-1.amazonaws.com/taptappun/project/food_forecast/images/icon.png"
  end

  def self.search_photo_url(keyword:)
    http_client = HTTPClient.new
    response = http_client.get("https://api.photozou.jp/rest/search_public.json", {keyword: keyword}, {})
    photozoures = JSON.parse(response.body)
    photoes = photozoures["info"]["photo"] || []
    if photoes.present?
      return photoes.sample["image_url"]
    else
      return ""
    end
  end

  def self.search_spots_from_location(latitude:, longitude:, api: :gnavi)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    now = Time.now
    request_hash_common = {
      range: 3,
      format: "json",
    }
    if (11..13).cover?(now.hour)
      #ランチやっているか
      request_hash_common[:lunch] = 1
    elsif (0..2).cover?(now.hour) || now.hour == 23
      #深夜営業しているか
      request_hash_common[:midnight] = 1
    end

    http_client = HTTPClient.new
    if api.to_s == "gnavi"
      request_hash = request_hash_common.merge({
        keyid: apiconfig["gnavi"]["apikey"],
        input_coordinates_mode: 2,
        coordinates_mode: 2,
        latitude: latitude,
        longitude: longitude,
        hit_per_page: 100
        #offset: 1,
        #no_smoking: 1,
        #mobilephone: 1,
        #parking: 1,
        #deliverly 1 デリバリーあり
        #special_holiday_lunch: 1 土日特別ランチあり 0
        #breakfast: 1
        #until_morning: 1
      })
      if (7..10).cover?(now.hour)
        #朝食をやっているか
        request_hash[:breakfast] = 1
      elsif (14..16).cover?(now.hour)
        #遅めのランチをやっているか
        request_hash[:late_lunch] = 1
      elsif (3..5).cover?(now.hour)
        #朝までやっているか
        request_hash[:until_morning] = 1
      end
      response = http_client.get(GNAVI_API_URL, request_hash, {})
    elsif api.to_s == "recruit"
      request_hash = request_hash_common.merge({
        key: apiconfig["recruit"]["apikey"],
        lat: latitude,
        lng: longitude,
        datum: "world",
        count: 100
      })
      response = http_client.get(HOTPEPPER_API_URL, request_hash, {})
    else
      response = http_client.get(GOOGLE_PLACE_API_URL, request_hash, {})
    end
    return JSON.parse(response.body)
  end

  def search_and_mix_and_shuffle(latitude:, longitude:)
    gnavi_hash = FoodForecast::UserWeatherLocation.search_spots_from_location(
      latitude: latitude,
      longitude: longitude,
      api: "gnavi"
    )
    recruit_hash = FoodForecast::UserWeatherLocation.search_spots_from_location(
      latitude: latitude,
      longitude: longitude,
      api: "recruit"
    )
    gnavi_array = gnavi_hash["rest"].map do |hash|
      hash["information_type"] = "gnavi"
      hash
    end

    recruit_array = recruit_hash["results"]["shop"].map do |hash|
      hash["information_type"] = "recruit"
      hash
    end

    result_array = (gnavi_array + recruit_array)

    return result_array.sample(5)
  end

  def search_and_recommend_spots!
    information_type = "recruit"
    recommend_array = self.search_and_mix_and_shuffle(
      latitude: self.lat,
      longitude: self.lon
    )

    recommends = []
    transaction do
      recommend_array.each do |hash|
        request_hash = {
          user_id: self.user_id,
          user_location_id: self.id,
          information_type: hash["information_type"],
          place_id: hash["id"],
          place_name: hash["name"],
          place_name_reading: hash["name_kana"],
          address: hash["address"],
          recommended_at: Time.current,
          page_number: 0
        }
        if hash["information_type"].to_s == "gnavi"
          request_hash["phone_number"] = hash["tel"] if hash["tel"].present?
          request_hash["latitude"] = hash["latitude"] if hash["latitude"].present?
          request_hash["longitude"] = hash["longitude"] if hash["longitude"].present?
          if hash["pr"]["pr_long"].present?
            description = hash["pr"]["pr_short"]
            if description.size > 60
              description = description[0..56] + "..."
            end
            request_hash["place_description"] = description
          else
            request_hash["place_description"] = hash["name"]
          end
          if hash["image_url"]["shop_image1"].present?
            request_hash["image_url"] = hash["image_url"]["shop_image1"]
          else
            request_hash["image_url"] = FoodForecast::UserWeatherLocation.icon_url
          end
          request_hash["url"] = hash["url"] if hash["url"].present?
          request_hash["coupon_url"] = hash["coupon_url"]["pc"] if hash["coupon_url"]["pc"].present?
          request_hash["opentime"] = hash["opentime"] if hash["opentime"].present?
          request_hash["holiday"] = hash["holiday"] if hash["holiday"].present?
        elsif hash["information_type"].to_s == "recruit"
          request_hash.merge!({
            latitude: hash["lat"],
            longitude: hash["lng"],
            phone_number: FoodForecast::UserWeatherLocation.search_phone_number(hash["shop_detail_memo"]),
            place_description: hash["catch"] || hash["name"],
            image_url: hash["photo"]["mobile"]["l"],
            url: hash["urls"]["pc"],
            coupon_url: hash["coupon_urls"]["sp"],
            opentime: hash["open"],
            holiday: hash["close"]
          })
        end
        output = self.restaurant_outputs.create!(request_hash)
        recommends << output
      end
    end
    return recommends
  end

end
