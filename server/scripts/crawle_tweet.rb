apiconfig = YAML.load(File.open("config/apiconfig.yml"))

client = Twitter::REST::Client.new do |config|
    config.consumer_key        = apiconfig["twitter"]["consumer_key"]
    config.consumer_secret     = apiconfig["twitter"]["consumer_secret"]
    config.access_token        = apiconfig["twitter"]["access_token_key"]
    config.access_token_secret = apiconfig["twitter"]["access_token_secret"]
end

natto = Natto::MeCab.new
#parser = CaboCha::Parser.new

is_all = false

start_time = Time.now
limit_span = (15.minutes.second / 180).to_i

serach_keyword = TweetSeed::ERO_KOTOBA_BOT
#serach_keyword = TweetSeed::AEGIGOE_BOT
last_id = TweetSeed.where(search_keyword: serach_keyword).last.try(:tweet_id_str)

=begin
natto.parse("マンゴスチン") do |n|
  puts "#{n.surface}\t#{n.feature}"
end
=end

while is_all == false do
  sleep limit_span
  tweet_seeds = []
  options = {:count => 100}
  if last_id.present?
  	options[:max_id] = last_id.to_i
  end
  tweet_results = client.user_timeline(serach_keyword, options)
  is_all = tweet_results.size < 100
  tweet_results.each do |status|
    next if status.blank?
    tweet_seed = TweetSeed.new
    tweet_seed.tweet_id_str = status.id.to_s
    tweet_seed.search_keyword = serach_keyword
    tweet_seed.sanitized(status.text)
    tweet_seeds << tweet_seed
  end
  last_id = tweet_results.last.try(:id).to_i - 1
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