require 'google/apis/youtube_v3'

class YoutubeRecord < ApplicationRecord
  self.abstract_class = true

  def self.crawl_loop_request(&block)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = apiconfig["google_api"]["key"]
    page_token = ExtraInfo.read_extra_info[table_name]
    begin
      get_list = block.call(youtube, page_token)
      page_token = get_list.next_page_token
      ExtraInfo.update({table_name => page_token})
    end while page_token.present?
  end
end