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

  def self.search_spots_from_location(latitude:, longitude:, api: :gnavi)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    http_client = HTTPClient.new
    if api.to_s == "gnavi"
      request_hash = {
        keyid: apiconfig["gnavi"]["apikey"],
        latitude: latitude,
        longitude: longitude,
        range: 3,
        #lunch: 1,
        #late_lunch: 1,
        #midnight: 1,
        format: "json",
        #offset: 1,
        #no_smoking: 1,
        #mobilephone: 1,
        #parking: 1,
        #deliverly 1 デリバリーあり
        #special_holiday_lunch: 1 土日特別ランチあり 0
        #breakfast: 1
        #until_morning: 1
      }
      response = http_client.get(GNAVI_API_URL, request_hash, {})
    elsif api.to_s == "recruit"
      request_hash = {
        key: apiconfig["recruit"]["apikey"],
        lat: latitude,
        lng: longitude,
        range: 3,
#        lunch: 1,
#        midnight_meal: 1,
#        midnight: 1,
        format: "json",
        count: 100
      }
      response = http_client.get(HOTPEPPER_API_URL, request_hash, {})
    else
      response = http_client.get(GOOGLE_PLACE_API_URL, request_hash, {})
    end
    return JSON.parse(response.body)
  end

  def self.search_phone_number(text)
    return text.match(/[0-9]{10,11}|\d{2,4}-\d{2,4}-\d{4}/).to_s
  end

  def search_and_recommend_spots!(event:)
    location_message = event["message"]
    information_type = "recruit"
    response_hash = Spotgacha::LinebotFollowerUser.search_spots_from_location(
      latitude: location_message["latitude"],
      longitude: location_message["longitude"],
      api: information_type
    )

    input = self.input_locations.create!(
      latitude: location_message["latitude"],
      longitude: location_message["longitude"],
      address: location_message["address"]
    )
    recommends = []
    if api.to_s == "gnavi"
      response_hash["rest"].sample(3).each do |hash|
        common = {
          input_location_id: input.id,
          information_type: information_type,
          place_id: hash["id"],
          place_name: hash["name"],
          place_name_reading: hash["name_kana"],
          address: hash["address"],
          recommended_at: Time.current,
        }

        output = self.output_recommends.create!(
          common.merge({
            latitude: hash["latitude"],
            longitude: hash["longitude"],
            phone_number: hash["tel"],
            place_description: hash["pr"]["pr_long"] || hash["name"],
            image_url: hash["image_url"]["shop_image1"],
            url: hash["url"],
            coupon_url: hash["coupon_url"]["pc"],
          })
        )
        recommends << output
      end
    elsif api.to_s == "recruit"
      response_hash["results"]["shop"].sample(3).each do |hash|
        common = {
          input_location_id: input.id,
          information_type: information_type,
          place_id: hash["id"],
          place_name: hash["name"],
          place_name_reading: hash["name_kana"],
          address: hash["address"],
          recommended_at: Time.current,
        }
        output = self.output_recommends.create!(
          common.merge({
            latitude: hash["lat"],
            longitude: hash["lng"],
            phone_number: Spotgacha::LinebotFollowerUser.search_phone_number(hash["shop_detail_memo"]),
            place_description: hash["genre"]["catch"] || hash["name"],
            image_url: hash["photo"]["mobile"]["l"],
            url: hash["urls"]["pc"],
            coupon_url: hash["coupon_urls"]["sp"],
          })
        )
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
