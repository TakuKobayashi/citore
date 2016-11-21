# == Schema Information
#
# Table name: crawl_schedulers
#
#  id             :integer          not null, primary key
#  state          :integer          default(0), not null
#  search_kind    :integer          default(0), not null
#  search_word    :string(255)      not null
#  resource_type  :string(255)
#  resource_id    :integer
#  start_time     :datetime
#  completed_time :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class CrawlScheduler < ApplicationRecord
  def self.tweet_crawl(action_name, search_word, &block)
  	apiconfig = YAML.load(File.open("config/apiconfig.yml"))
  	client = Twitter::REST::Client.new do |config|
      config.consumer_key        = apiconfig["twitter"]["consumer_key"]
      config.consumer_secret     = apiconfig["twitter"]["consumer_secret"]
      config.access_token        = apiconfig["twitter"]["access_token_key"]
      config.access_token_secret = apiconfig["twitter"]["access_token_secret"]
    end
    is_all = false
    start_time = Time.now
    limit_span = (15.minutes.second / 180).to_i

    #last_id = TweetSeed.where(search_keyword: serach_keyword).last.try(:tweet_id_str)
    while is_all == false do
      sleep limit_span
      options = {:count => 100}
#      if last_id.present?
#  	    options[:max_id] = last_id.to_i
#      end

      tweet_results = client.send(action_name, serach_keyword, options)
      is_all = tweet_results.size < 100
      block.call(tweet_results)
    end
  end
end
