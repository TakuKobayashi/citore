# == Schema Information
#
# Table name: datapool_image_meta
#
#  id                :bigint(8)        not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  other_src         :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_image_meta_on_origin_src  (origin_src)
#  index_datapool_image_meta_on_title       (title)
#

class Datapool::InstagramImageMetum < Datapool::ImageMetum
  INSTAGRAM_TAG_SEARCH_API_URL = "https://www.instagram.com/explore/tags/"

  def self.crawl_images!(keyword:)
    all_images = []
    counter = 0
    images = []
    doc = RequestParser.request_and_parse_html(url: INSTAGRAM_TAG_SEARCH_API_URL + keyword.to_s + "/")
    target_json_string = doc.css("script").map{|js_dom| js_dom.text.match(/\{.*}/).to_s }[2]
    return nil if target_json_string.blank?
    json_hash = {}
    begin
      json_hash = JSON.parse(target_json_string)
    rescue JSON::ParserError => e
      json_hash = {}
    end
    json_hash["entry_data"]["TagPage"].each do |hash|
      hash["graphql"]["hashtag"]
      #https://www.instagram.com/graphql/query/?query_hash=ded47faa9a1aaded10161a2ff32abb6b&variables=%7B%22tag_name%22%3A%22hashtag%22%2C%22first%22%3A6%2C%22after%22%3A%22AQBaFbFAFi8BjvNFCwHWZDiqA4SWwRTf9jVotEHCJPSKWiY8mgm-tg2VwyfWfQp1CUT1TFE3D5DTqUTluAEVwTIV67xppOzuI7OgTIB2TeuBCQ%22%7D
      #query
      #{
      #  query_hash: ded47faa9a1aaded10161a2ff32abb6b
      #  variables: {"tag_name":"hashtag","first":6,"after":"AQBaFbFAFi8BjvNFCwHWZDiqA4SWwRTf9jVotEHCJPSKWiY8mgm-tg2VwyfWfQp1CUT1TFE3D5DTqUTluAEVwTIV67xppOzuI7OgTIB2TeuBCQ"}
      #}
      #request header
      #{
      #  :authority: www.instagram.com
      #  :path: /graphql/query/?query_hash=ded47faa9a1aaded10161a2ff32abb6b&variables=%7B%22tag_name%22%3A%22hashtag%22%2C%22first%22%3A6%2C%22after%22%3A%22AQBaFbFAFi8BjvNFCwHWZDiqA4SWwRTf9jVotEHCJPSKWiY8mgm-tg2VwyfWfQp1CUT1TFE3D5DTqUTluAEVwTIV67xppOzuI7OgTIB2TeuBCQ%22%7D
      #  cookie: csrftoken=1hQXvpaBvOPFkRe5neqRpnlm4cD4M5HH; mid=WnF7-AAEAAHv78teJV4zW5h2gXQC; fbm_124024574287414=base_domain=.instagram.com; rur=FTW; fbsr_124024574287414=tBZYx7w6U8gIQg6Q4oa7Ym3MF-W5tS-7y7N5E2WB_no.eyJhbGdvcml0aG0iOiJITUFDLVNIQTI1NiIsImNvZGUiOiJBUUNMRWFOdjVHYjl2enc5blFYV0JfSHpPaW8ydUJSOFBJOXJzUUdGbEUxZHYySXRmUFAwVWo3RTNaVUU1X19MY0U3U0Fob0lMM2hLMUlXcTZya080bldkWUZaWDFsNFdlVVE0aUdSdjFWQW1kNERoSFkzc0xEZkNQVXU2eUFRWjNGWk83TWRaTHBQVWtJSndVY0VnOGtIalZ5RHpTTFFQTkpnTzljeVA3eEdNYnhib3pQUVBINC1YWlVLU3VZdjJWMWNhWDIzTTlSVi1UQXNMVEM0WDQzcHlXTktna3BaODN1LVlYQWVDT1ZqRU1LLURjSmdGaVl1Zk9nOWdWUVNkdFBycndOY2xMWnBjSk0tMnU2YU5PX3R2TDM0MnczWk92X09KUWNhZksxMlU3TXZfMTB3bXo0VG1qQnZ1NnJzZVR1TFVieDNleDRoWGNQcTRsN2Y0aUJvcCIsImlzc3VlZF9hdCI6MTUyNjYyNDYxOCwidXNlcl9pZCI6IjEwMDAwMTg5Mjc5OTM0MCJ9; urlgen="{\"time\": 1526624603\054 \"27.110.34.94\": 10021}:1fJYnr:LHcSlC2cJ-KGO_RQaRyH02wjIk8"
      #  referer: https://www.instagram.com/explore/tags/hashtag/
      #  user-agent: Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.139 Mobile Safari/537.36
      #  x-instagram-gis: a249f8ce6a8e16edd3d17b761bb1a4c5
      #  x-requested-with: XMLHttpRequest
      #}
    end
  end
end
