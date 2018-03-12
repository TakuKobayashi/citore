require 'xmlsimple'

module TextAnalyzer
  MECAB_NEOLOGD_DIC_PATH = "/usr/local/lib/mecab/dic/mecab-ipadic-neologd"

  def self.get_natto
    @@natto ||= Natto::MeCab.new(dicdir: ApplicationRecord::MECAB_NEOLOGD_DIC_PATH)
    return @@natto
  end

  def self.parsed_from_cabocha(text)
    @@cabocha ||= CaboCha::Parser.new(MECAB_NEOLOGD_DIC_PATH)
    tree = @@cabocha.parse(text)
    xml_to_hash = XmlSimple.xml_in(tree.toString(CaboCha::FORMAT_XML))
    return xml_to_hash
  end

  def self.reading(text)
    #記号を除去
    sanitaized_word = delete_symbols(text)
    word = separate_urls(sanitaized_word).first
    reading_array = []
    natto = self.get_natto
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

  def self.get_location_words(text)
    place_names = []
    natto = self.get_natto
    natto.parse(text) do |n|
      next if n.surface.blank?
      features = n.feature.split(",")
      if features[1] == "固有名詞" && features[2] == "地域"
        place_names << n.surface
      end
    end
    return place_names
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