class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  MECAB_NEOLOGD_DIC_PATH = "/usr/local/lib/mecab/dic/mecab-ipadic-neologd"

  def self.request_and_parse_html(url)
    http_client = HTTPClient.new
    response = http_client.get(url, {}, {})
    doc = Nokogiri::HTML.parse(response.body)
    return doc
  end

  def self.basic_sanitize(text)
    #絵文字を除去
    sanitized_word = text.each_char.select{|c| c.bytes.count < 4 }.join('')
    #全角半角をいい感じに整える
    sanitized_word = Charwidth.normalize(sanitized_word)
    
    # 余分な空欄を除去
    sanitized_word.strip!
    return sanitized_word
  end

  def self.separate_urls(text)
    result = text
    #URLがあったらそれは別にする
    urls = URI.extract(result)
    urls.each do |url|
      result.gsub!(url, "")
    end
    return result, urls
  end

  #記号を除去
  def self.delete_symbols(text)
    return text.gsub(/[【】、。《》「」〔〕・（）［］｛｝！＂＃＄％＆＇＊＋，－．／：；＜＝＞？＠＼＾＿｀｜￠￡￣\(\)\[\]<>{},!? \.\-\+\\~^='&%$#\"\'_\/;:*‼•一]/, "")
  end

  def self.separate_kaomoji(text)
    result = text
    kaomojis = text.scan(/(?:[^0-9A-Za-zぁ-ヶ一-龠]|[ovっつ゜ニノ三二])*[\(∩꒰（](?!(?:[0-9A-Za-zぁ-ヶ一-龠]|[ｦ-ﾟ]){3,}).{3,}[\)∩꒱）](?:[^0-9A-Za-zぁ-ヶ一-龠]|[ovっつ゜ニノ三二])*/)
    kaomojis.each do |kaomoji|
      result.gsub!(kaomoji, "")
    end
    return result, kaomojis
  end

  def self.reading(text)
    #記号を除去
    sanitaized_word = delete_symbols(text)
    word, urls = separate_urls(sanitaized_word)
    reading_array = []
    natto = Natto::MeCab.new(dicdir: MECAB_NEOLOGD_DIC_PATH)
    natto.parse(word) do |n|
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

  # カッコの中身の文を分ける
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
end
