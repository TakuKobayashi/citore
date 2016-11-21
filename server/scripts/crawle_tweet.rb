serach_keyword = TweetSeed::ERO_KOTOBA_BOT
#serach_keyword = TweetSeed::AEGIGOE_BOT
#last_id = TweetSeed.where(search_keyword: serach_keyword).last.try(:tweet_id_str)

CrawlScheduler.tweet_crawl("user_timeline", serach_keyword, {}) do |tweet_statuses|
  tweet_seeds = []
  tweet_statuses.each do |status|
    next if status.blank?
    sanitaized_word = TweetSeed.sanitized(status.text)
    split_words = TweetSeed.bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end
    split_words.each do |word|
      reading = TweetSeed.reading(word)
      tweet_seed = TweetSeed.new
      tweet_seed.tweet_id_str = status.id.to_s
      tweet_seed.search_keyword = serach_keyword
      tweet_seeds << tweet_seed
    end
  end
  #last_id = tweet_statuses.select{|s| s.try(:id).present? }.min_by{|s| s.id.to_i }.try(:id).to_i
  TweetSeed.import(tweet_seeds)
end

=begin
client.search('エロく聞こえる言葉 -rt', :lang => "ja", :count => 100, :max_id => last_id).map do |status|
  tweet_seed = TweetSeed.new
  tweet_seed.tweet_id_str = status.id.to_s
  tweet_seed.tweet = status.text.each_char.select{|c| c.bytes.count < 4 }.join('')
  tweet_seeds << tweet_seed
  natto.parse(status.text) do |n|
    puts "#{n.surface}\t#{n.feature}"
  end
  tree = parser.parse(status.text)
  puts tree.toString(CaboCha::FORMAT_TREE)
end
=end