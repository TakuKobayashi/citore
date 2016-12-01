class TweetVoiceSeedDynamo
  include Aws::Record

  string_attr  :key,  hash_key: true
  string_attr  :reading, range_key: true
  string_attr  :uuid
  string_attr :keyword
  integer_attr :appear_count
  list_attr    :twitter_info
  map_attr     :options

  ERO_KOTOBA_BOT = "ero_kotoba_bot"
  AEGIGOE_BOT = "aegigoe_bot"

  ERO_KOTOBA_KEY = "ero_kotoba"

  def self.generate!(text, keyword, twitter_info = {}, options = {})
    puts text
  	reading = reading(text)
    words = ngram(text, 2).uniq
    words.map do |key|
      tweet = TweetVoiceSeedDynamo.find(key: key, reading: reading,keyword: keyword)
      if tweet.blank?
        tweet = TweetVoiceSeedDynamo.new
        tweet.key = key
        tweet.reading = reading
        tweet.uuid = SecureRandom.hex
        tweet.keyword = keyword
      end
      tweet.appear_count = tweet.appear_count.to_i + 1
      if twitter_info.present?
        if tweet.twitter_info.blank?
          tweet.twitter_info = []
        end
        tweet.twitter_info += [twitter_info]
      end
      if options.present?
        tweet.options = options
      end
      tweet.save!
      tweet
    end
  end

  def self.sanitized(text)
    #絵文字を除去
    sanitized_word = text.each_char.select{|c| c.bytes.count < 4 }.join('')
    #全角半角をいい感じに整える
    sanitized_word = Charwidth.normalize(sanitized_word)
    #返信やハッシュタグを除去
    sanitized_word = sanitized_word.gsub(/[#＃@][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー_]+/, "")
    # 余分な空欄を除去
    sanitized_word.strip!
    return sanitized_word
  end

  def self.reading(text)
    #記号を除去
    sanitaized_word = text.gsub(/[、。《》「」〔〕・（）［］｛｝！＂＃＄％＆＇＊＋，－．／：；＜＝＞？＠＼＾＿｀｜～￠￡￣\(\)\[\]<>{}]/, "")
    reading_array = []
    natto = Natto::MeCab.new
    natto.parse(sanitaized_word) do |n|
      next if n.surface.blank?
      csv = n.feature.split(",")
      reading = csv[7]
      if reading.blank?
        reading = n.surface
      end
      reading_array << reading
    end
    return reading_array.join("")
  end

  # カッコの中身の文だけ取得
  def self.bracket_split(text)
    bracket_words = text.scan(/[「\(].+?[」\)]/)
    split_words = text.split(/[「\(].+?[」\)]/)
    words = split_words.map.with_index do |word, index|
      bw = bracket_words[index].to_s.strip
      [word.strip,  bw[1..(bw.size - 2)]]
    end.flatten.compact
    return words
  end

  def self.ngram(word, n)
    characters = word.split(//u)
    return [word] if characters.size <= n
    return characters.each_cons(n).map(&:join)
  end

  def self.generate_data_and_voice(keyword, text, twitter_info = {}, options = {})
    sanitaized_word = sanitized(text)
    puts sanitaized_word

    split_words = bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end

    split_words.each do |word|
      generate!(word, keyword, twitter_info, options)
      puts "generate_voice"
      VoiceDynamo.all_speacker_names.each do |speacker|
        VoiceDynamo.generate_and_upload_voice(reading(word), ERO_KOTOBA_KEY, speacker)
      end
    end
  end

  def self.to_sugarcoat(text, options = {})
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    sanitaized_word = sanitized(text)
    split_words = bracket_split(sanitaized_word)
    if split_words.blank?
      split_words = [sanitaized_word]
    end
    extra = CrawlScheduler.read_extra_info

    words = split_words.map do |word|
      tree_separate_words = []
      parser = CaboCha::Parser.new
      tree = parser.parse(word)
      output = tree.toString(CaboCha::FORMAT_LATTICE)
      output_lines = output.split("\n")
      output_lines.each do |line|
        cells = line.split(" ")
        if cells[0].blank? || cells[0] == "*"
          tree_separate_words = []
          next
        end
        next if cells[1].blank?
        features = cells[1].split(",")
        score = get_word_score(features[0].force_encoding("utf-8"), cells[0].force_encoding("utf-8"))
        if score.blank?
          tree_separate_words << cells[0]
          next
        end
        if score >= extra["ja_average_score"].to_f
          tree_separate_words << cells[0]
          next
        end
        list = `http -a #{apiconfig["metadata_wordassociator"]["username"]}:#{apiconfig["metadata_wordassociator"]["password"]} GET wordassociator.ap.mextractr.net/word_associator/api_query query==#{cells[0]}`
        max_word = JSON.parse(list).max_by{|arr| get_word_score(arr[0].strip, features[0].strip) }
        tree_separate_words << max_word[0]
      end
      tree_separate_words.join("")
    end
    return words
  end

  def self.get_word_score(cverb, word)
    verbs = EmotionalWordDynamo::PARTS.keys
    verb = verbs.detect{|v| cverb.include?(v) }
    return nil if verb.blank?
    v = EmotionalWordDynamo::PARTS[verb]
    reading_word = reading(word)
    emotion = EmotionalWordDynamo.find(word: word, reading: reading_word, part: v)
    return nil if emotion.blank?
    return emotion.score.to_f
  end
end
