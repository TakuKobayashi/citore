# == Schema Information
#
# Table name: linebot_follower_users
#
#  id             :integer          not null, primary key
#  type           :string(255)      not null
#  line_user_id   :string(255)      not null
#  display_name   :string(255)      not null
#  picture_url    :string(255)
#  status_message :text(65535)
#  unfollow       :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_linebot_follower_users_on_line_user_id_and_type  (line_user_id,type) UNIQUE
#

class Spotgacha::LinebotFollowerUser < LinebotFollowerUser
  has_many :input_locations, as: :input_user, class_name: 'Spotgacha::InputLocation'
  has_many :output_recommends, as: :output_user, class_name: 'Spotgacha::OutputRecommend'

  #http://webservice.recruit.co.jp/hotpepper/reference.html
  HOTPEPPER_API_URL = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/"

  #http://api.gnavi.co.jp/api/manual/restsearch/
  GNAVI_API_URL = "https://api.gnavi.co.jp/RestSearchAPI/20150630/"

  #https://developers.google.com/places/web-service/search?hl=ja
　GOOGLE_PLACE_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters"

  def self.icon_url
    return ApplicationRecord::S3_ROOT_URL + "project/spotgacha/icon/spotgacha_icon.jpg"
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
        keyid: ENV.fetch('GNAVI_APIKEY', ''),
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
        key: ENV.fetch('RECRUIT_APIKEY', ''),
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
    gnavi_hash = Spotgacha::LinebotFollowerUser.search_spots_from_location(
      latitude: latitude,
      longitude: longitude,
      api: "gnavi"
    )
    recruit_hash = Spotgacha::LinebotFollowerUser.search_spots_from_location(
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

    appeared_places = self.output_recommends.pluck(:information_type, :place_id, :is_select)
    candidates = result_array.reject do |hash|
      appeared_places.any?{|information_type, place_id, is_select| information_type == hash["information_type"].to_s && place_id == hash["id"].to_s }
    end
    if candidates.blank?
      candidates = result_array
    end

    return candidates.sample(5)
  end

  def search_and_recommend_spots!(event:)
    location_message = event["message"]
    information_type = "recruit"
    recommend_array = self.search_and_mix_and_shuffle(
      latitude: location_message["latitude"],
      longitude: location_message["longitude"]
    )

    input = self.input_locations.create!(
      latitude: location_message["latitude"],
      longitude: location_message["longitude"],
      address: location_message["address"]
    )
    recommends = []
    transaction do
      recommend_array.each do |hash|
        request_hash = {
          input_location_id: input.id,
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
            request_hash["image_url"] = Spotgacha::LinebotFollowerUser.icon_url
          end
          request_hash["url"] = hash["url"] if hash["url"].present?
          request_hash["coupon_url"] = hash["coupon_url"]["pc"] if hash["coupon_url"]["pc"].present?
          request_hash["opentime"] = hash["opentime"] if hash["opentime"].present?
          request_hash["holiday"] = hash["holiday"] if hash["holiday"].present?
        elsif hash["information_type"].to_s == "recruit"
          request_hash.merge!({
            latitude: hash["lat"],
            longitude: hash["lng"],
            phone_number: Spotgacha::LinebotFollowerUser.search_phone_number(hash["shop_detail_memo"]),
            place_description: hash["catch"] || hash["name"],
            image_url: hash["photo"]["mobile"]["l"],
            url: hash["urls"]["pc"],
            coupon_url: hash["coupon_urls"]["sp"],
            opentime: hash["open"],
            holiday: hash["close"]
          })
        end
        output = self.output_recommends.create!(request_hash)
        recommends << output
      end
    end
    return recommends

#range	検索範囲	ある地点からの範囲内のお店の検索を行う場合の範囲を5段階で指定できます。たとえば300m以内の検索ならrange=1を指定します	1: 300m
#2: 500m
#3: 1000m (初期値)
#4: 2000m
#5: 3000m
#携帯クーポン掲載	携帯クーポンの有無で絞り込み条件を指定します。		1：携帯クーポンなし
#0：携帯クーポンあり
#指定なし：絞り込みなし
#lunch	ランチあり	「ランチあり」という条件で絞り込むかどうかを指定します。	 	0:絞り込まない（初期値）
#1:絞り込む
#midnight	23時以降も営業	「23時以降も営業」という条件で絞り込むかどうかを指定します。	 	0:絞り込まない（初期値）
#1:絞り込む
#midnight_meal	23時以降食事OK	「23時以降食事OK」という条件で絞り込むかどうかを指定します。	 	0:絞り込まない（初期値）
#1:絞り込む
#    count	1ページあたりの取得数	検索結果の最大出力データ数を指定します。	 	初期値：10、最小1、最大100
#format	レスポンス形式	レスポンスをXMLかJSONかJSONPかを指定します。JSONPの場合、さらにパラメータ callback=コールバック関数名 を指定する事により、javascript側コールバック関数の名前を指定できます。	 	初期値:xml。xml または json または jsonp。
#genre	お店ジャンルコード	お店のジャンル(サブジャンル含む)で絞込むことができます。指定できるコードについてはジャンルマスタAPI参照	 	*2
#food	料理コード	料理（料理サブを含む)で絞りこむことができます。指定できるコードについては料理マスタAPI参照	 	5個まで指定可。*2
#budget	検索用予算コード	予算で絞り込むことができます。指定できるコードについては予算マスタAPI参照	 	2個まで指定可。*2

  end
end
