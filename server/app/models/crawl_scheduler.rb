# == Schema Information
#
# Table name: crawl_schedulers
#
#  id             :integer          not null, primary key
#  state          :integer          default("pending"), not null
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
  enum state: { pending: 0, crawling: 1, stay: 2, completed: 3}

  def self.add_crawl_info(search_action:, resource_type:, search_word:)
    scedular_hash = {state: CrawlScheduler[:pending], search_action: search_action, resource_type: resource_type, search_word: search_word}
    hash = ExtraInfo.read_extra_info
    hash[:crawl_info] << scedular_hash
    ExtraInfo.update(hash)
  end

  def self.update_crawl_info(new_crawl_hash)
    hash = ExtraInfo.read_extra_info
    hash[:crawl_info] = hash["crawl_info"].map do |h|
      result = h
      if h["uuid"] == new_crawl_hash["uuid"]
        result = new_crawl_hash
      end
      result
    end
    ExtraInfo.update(hash)
  end

  def self.tweet_crawl(keyword, crawl_options, &block)
    client = TwitterRecord.get_twitter_rest_client("citore")
    is_all = false
    start_time = Time.now
    limit_span = (15.minutes.second / 180).to_i

    crawl_info = ExtraInfo.read_extra_info["crawl_info"]
    crawls = crawl_info.select{|hash| hash["state"] != CrawlScheduler.states[:completed] && hash["keyword"] == keyword}
    crawls.each do |crawl|
      last_id = crawl["last_id"]
      crawl["start_time"] = Time.now
      while is_all == false do
        crawl["state"] = CrawlScheduler.states[:crawling]
        puts crawl
        update_crawl_info(crawl)
        sleep limit_span
        options = crawl_options.merge({:count => 100})
        if last_id.present?
          options[:max_id] = last_id.to_i
        end
        puts options

        tweet_results = client.send(crawl["search_action"], crawl["search_word"], options)
        is_all = tweet_results.size < 100
        block.call(tweet_results)
        last_id = tweet_results.select{|s| s.try(:id).present? }.min_by{|s| s.id.to_i }.try(:id).to_i
        crawl["last_id"] = last_id
        crawl["state"] = CrawlScheduler.states[:stay]
        update_crawl_info(crawl)
      end
      crawl["complete_time"] = Time.now
      crawl["state"] = CrawlScheduler.states[:completed]
      update_crawl_info(crawl)
    end
  end
end
