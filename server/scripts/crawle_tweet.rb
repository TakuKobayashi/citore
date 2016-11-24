CrawlScheduler.tweet_crawl("citore", {}) do |tweet_statuses|
  tweet_statuses.each do |status|
    next if status.blank?
    TweetSeed.generate_data_and_voice(status.text, {tweet_id: status.id, tweet_user_id: status.user.id, tweet_user_name: status.user.name})
  end
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