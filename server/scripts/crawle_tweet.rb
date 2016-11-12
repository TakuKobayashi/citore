apiconfig = YAML.load(File.open("config/apiconfig.yml"))

client = Twitter::REST::Client.new do |config|
    config.consumer_key        = apiconfig["twitter"]["consumer_key"]
    config.consumer_secret     = apiconfig["twitter"]["consumer_secret"]
    config.access_token        = apiconfig["twitter"]["access_token_key"]
    config.access_token_secret = apiconfig["twitter"]["access_token_secret"]
end

natto = Natto::MeCab.new
parser = CaboCha::Parser.new

last_id = nil
client.search('エロく聞こえる言葉 -rt', :lang => "ja", :count => 100, :max_id => last_id).map do |status|
  natto.parse(status.text) do |n|
    puts "#{n.surface}\t#{n.feature}"
  end
  tree = parser.parse(status.text)
  puts tree.toString(CaboCha::FORMAT_TREE)
end