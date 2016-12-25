apiconfig = YAML.load(File.open("config/apiconfig.yml"))
TweetStream.configure do |config|
  config.consumer_key       = apiconfig["twitter"]["consumer_key"]
  config.consumer_secret    = apiconfig["twitter"]["consumer_secret"]
  config.oauth_token        = apiconfig["twitter"]["access_token_key"]
  config.oauth_token_secret = apiconfig["twitter"]["access_token_secret"]
  config.auth_method        = :oauth
end

natto = Natto::MeCab.new(dicdir: TweetVoiceSeedDynamo::MECAB_NEOLOGD_DIC_PATH)

client = TweetStream::Client.new
client.sample do |status|
  next if status.lang != "ja"
  sanitaized_word = TweetVoiceSeedDynamo.sanitized(status.text)
  without_url_tweet, urls = TweetVoiceSeedDynamo.separate_urls(sanitaized_word)
  without_kaomoji_tweet, kaomojis = TweetVoiceSeedDynamo.separate_kaomoji(without_url_tweet)
  tweet_words = TweetVoiceSeedDynamo.bracket_split(without_kaomoji_tweet)
  tweet_words = tweet_words.map{|t| TweetVoiceSeedDynamo.delete_symbols(t) }

  begin
    tweet = TwitterWord.create!(
      twitter_user_id: status.user.id.to_s,
      twitter_user_name: status.user.screen_name.to_s,
      twitter_tweet_id: status.id.to_s,
      tweet: without_url_tweet,
      csv_url: urls.join(","),
      tweet_created_at: status.created_at
    )

    import_words = []
    appear_imports = {}
    kaomojis.each do |kaomoji|
      appears = appear_imports[kaomoji]
      if appears.present?
        count = appears[:appear_count]
      end
      appear_imports[kaomoji] = {word: kaomoji, part: EmotionalWordDynamo::KAOMOJI_PART, appear_count: count.to_i + 1}
    end

    tweet_words.each do |tweet_word|
      natto.parse(tweet_word) do |n|
        next if n.surface.blank?
        features = n.feature.split(",")
        part = EmotionalWordDynamo::PARTS[features[0]]
        next if part.blank? || part == "av"
        word = features[6]
        if word.blank? || word == "*"
          word = n.surface
        end
        appears = appear_imports[word]
        if appears.present?
          count = appears[:appear_count]
        end
        appear_imports[word] = {word: word, part: part, appear_count: count.to_i + 1}
      end
    end

    appear_words = []
    appear_imports.each do |word, hash|
      appear_word = AppearWord.new(hash)
      import_words << appear_word
    end
    AppearWord.import(import_words, on_duplicate_key_update: "appear_count = appear_count + VALUES(appear_count), `updated_at`=VALUES(`updated_at`)")
    ids = AppearWord.where(word: import_words.map(&:word), part: import_words.map(&:part)).pluck(:id)
    next if ids.blank?
    #なぜか謎のloadが入ってしまうのでimportするのは一回だけ
    values = ids.map{|id| "(" + ["NULL", id, tweet.id].join(",") + ")" }
    sql = "INSERT INTO `#{TwitterWordAppear.table_name}` (#{TwitterWordAppear.column_names.join(',')}) VALUES " + values.join(",")
    TwitterWordAppear.connection.execute(sql)
  rescue => e # => StandardError を catch
    puts e.message
  end
end