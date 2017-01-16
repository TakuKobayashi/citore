require 'google/apis/youtube_v3'

class YoutubeRecord < ApplicationRecord
  self.abstract_class = true

  def self.crawl_loop_request(&block)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = apiconfig["google_api"]["key"]
    page_token = ExtraInfo.read_extra_info[table_name]
    retry_counter = 0
    begin
      begin
        get_list = block.call(youtube, page_token)
        if get_list.next_page_token.blank?
          page_token = nil
        else
          page_token = get_list.next_page_token
        end
        ExtraInfo.update({table_name => page_token})
      rescue Exception => e
        logger = ActiveSupport::Logger.new("log/batch_error.log")
        console = ActiveSupport::Logger.new(STDOUT)
        logger.extend ActiveSupport::Logger.broadcast(console)
        logger.info("error message:" + e.message,to_s)
        puts "error message:" + e.message,to_s
        retry_counter += 1
        if retry_counter <= 5
          retry
        else
          puts "retried 5 times so go to next loop"
          break
        end
      end
    end while page_token.present?
  end
end