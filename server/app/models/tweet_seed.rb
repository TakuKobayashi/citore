# == Schema Information
#
# Table name: tweet_seeds
#
#  id             :integer          not null, primary key
#  tweet_id_str   :string(255)      not null
#  tweet          :string(255)      not null
#  search_keyword :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_tweet_seeds_on_search_keyword  (search_keyword)
#  index_tweet_seeds_on_tweet_id_str    (tweet_id_str) UNIQUE
#

class TweetSeed < ApplicationRecord
  self.abstract_class = true

  has_many :tweet_voices

  ERO_KOTOBA_BOT = "ero_kotoba_bot"
  AEGIGOE_BOT = "aegigoe_bot"

  VOICE_PARAMS = {
    ext: "wav",
    volume: 2.0,
    speed: 0.6,
    range: 2.0,
    pitch: 1.8,
    style: {"j" => "1.0"}
  }


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
    return text.scan(/[「\(].+?[」\)]/).map{|t| t[1..(t.size - 2)]}
  end

  def self.ngram(word, n)
    characters = word.split(//u)
    return [word] if characters.size <= n
    return characters.each_cons(n).map(&:join)
  end

  def self.to_sugarcoat(text, options = {})
    apiconfig = YAML.load(File.open("config/apiconfig.yml"))
    sanitaized_word = TweetSeed.sanitized(text)
    split_words = TweetSeed.bracket_split(sanitaized_word)
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
        tree_separate_words << cells[0]
        features = cells[1].split(",")
        puts features
        score = get_word_score(features[0].strip, cells[0].strip)
        next if score.blank?
        next if score >= extra["ja_average_score"].to_f
        list = `http -a #{apiconfig["metadata_wordassociator"]["username"]}:#{apiconfig["metadata_wordassociator"]["password"]} GET wordassociator.ap.mextractr.net/word_associator/api_query query==#{cells[0]}`
        max_word = list.max_by{|arr| get_word_score(arr[0].strip, features[0].strip) }
        tree_separate_words << max_word
      end
      tree_separate_words.join("")
    end
    return words
  end

  def self.get_word_score(cverb, word)
    verbs = EmotionalWordDictionary::PARTS.keys
    verb = verbs.detect{|v| cverb.include?(v) }
    return nil if verb.blank?
    v = EmotionalWordDictionary::PARTS[verb]
    emotion = EmotionalWordDynamo.find(word: word, part: v)
    return emotion.info["score"].to_f
  end
end
