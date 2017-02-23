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
  #http://webservice.recruit.co.jp/hotpepper/reference.html
  HOTPEPPER_API_URL = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/"

  #http://api.gnavi.co.jp/api/manual/restsearch/
  GNAVI_API_URL = "http://api.gnavi.co.jp/api/manual/restsearch/"

  #https://developers.google.com/places/web-service/search?hl=ja
　GOOGLE_PLACE_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters"

  def search_spots
    request_hash = {
      key: "",
      lat: 0,
      lng: 0,
      range: 3,
      lunch: 1,
      midnight_meal: 1,
      midnight: 1,
      format: "JSON",
      count: 100
    }
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
