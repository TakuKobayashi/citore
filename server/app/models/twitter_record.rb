class TwitterRecord < ApplicationRecord
  self.abstract_class = true

  CRAWL_STATES = {
    pending: 0,
    crawling: 1,
    stay: 2,
    completed: 3
  }

  ERO_KOTOBA_BOT = "ero_kotoba_bot"
  AEGIGOE_BOT = "aegigoe_bot"

  ERO_KOTOBA_KEY = "ero_kotoba"

  def self.sanitized(text)
    sanitized_word = ApplicationRecord.basic_sanitize(text)
    #返信やハッシュタグを除去
    sanitized_word = sanitized_word.gsub(/[#＃@][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー_]+/, "")
    #リツイートにRTとつける事が多いので、そこの部分は取り除く
    sanitized_word = sanitized_word.gsub(/RT[;: ]/, "")
    
    # 余分な空欄を除去
    sanitized_word.strip!
    return sanitized_word
  end

  def self.generate_data_and_voice!(text, twitter_word_id = nil)
    sanitaized_word = TwitterRecord.sanitized(text)
    puts sanitaized_word

    split_words = ApplicationRecord.bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end

    transaction do
      split_words.each do |word|
        twitter_record = try(:generate!, word, twitter_word_id)
        puts "generate_voice"
        VoiceWord.all_speacker_names.each do |speacker|
          VoiceWord.generate_and_upload_voice(twitter_record, ApplicationRecord.reading(word), speacker)
        end
      end
    end
  end


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

  def self.tweet_crawl(crawl_options, &block)
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = apiconfig["twitter"]["consumer_key"]
      config.consumer_secret     = apiconfig["twitter"]["consumer_secret"]
      config.access_token        = apiconfig["twitter"]["access_token_key"]
      config.access_token_secret = apiconfig["twitter"]["access_token_secret"]
    end
    is_all = false
    start_time = Time.now
    limit_span = (15.minutes.second / 180).to_i

    extra_info = ExtraInfo.read_extra_info
    crawl_info = extra_info[self.table_name] || {}

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
      ExtraInfo.update({self.table_name => crawl_info})
    end
  end
end