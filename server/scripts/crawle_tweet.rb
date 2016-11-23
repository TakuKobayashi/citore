CrawlScheduler.tweet_crawl("citore", {}) do |tweet_statuses|
  tweet_seeds = []
  tweet_statuses.each do |status|
    next if status.blank?
    sanitaized_word = TweetSeed.sanitized(status.text)
    puts sanitaized_word

    split_words = TweetSeed.bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end
    split_words.each do |word|
      reading = TweetSeed.reading(word)
      puts word
      natto = Natto::MeCab.new
      natto.parse(word) do |n|
        next if n.surface.blank?
        csv = n.feature.split(",")
        next if !csv[0].to_s.include?("動詞") && csv[0].to_s.include?("名詞")
        tweet = TweetVoiceSeedDynamo.find(key: n.surface, reading: reading)
        if tweet.blank?
          tweet = TweetVoiceSeedDynamo.new
        end
        next if tweet.try(:reading) == reading
        tweet.key = n.surface
        tweet.reading = reading
        tweet.info = {tweet_id: status.id, origin: sanitaized_word, tweet_user_id: status.user.id, tweet_user_name: status.user.name}
        tweet.save!
      end

      puts "generate_voice"
      Voice.all_speacker_names.each do |speacker|
        Voice.generate_and_upload_voice(reading, TweetVoiceSeedDynamo.to_s, speacker)
      end
    end
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