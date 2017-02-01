class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_save do
    update_cache!
  end

  before_destroy do
    destory_cache!
  end

  MECAB_NEOLOGD_DIC_PATH = "/usr/local/lib/mecab/dic/mecab-ipadic-neologd"

  def self.request_and_parse_html(url)
    http_client = HTTPClient.new
    response = http_client.get(url, {}, {})
    doc = Nokogiri::HTML.parse(response.body)
    return doc
  end

  def self.request_and_get_links_from_html(url)
    doc = request_and_parse_html(url)
    result = {}
    doc.css('a').select{|anchor| anchor[:href].present? && anchor[:href] != "/" }.each{|anchor| result[anchor[:href]] = anchor.text }
    return result
  end

  def self.basic_sanitize(text)
    #絵文字を除去
    sanitized_word = text.encode('SJIS', 'UTF-8', invalid: :replace, undef: :replace, replace: '').encode('UTF-8')
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

  def self.memory_cache!
    CacheStore::CACHE.write(self.table_name, self.all.index_by(&:id))
  end

  def self.find_by_used_cache(filter = {})
    records = CacheStore::CACHE.read(self.table_name)
    if records.blank?
      return self.find_by(filter)
    end
    if filter.key?(:id) || filter.key?("id")
      return records[filter["id"]] || records[filter[:id]]
    end
    return records.values.detect{|r| filter.all?{|k, v| r.send(k) == v } }
  end

  def self.where_used_cache(filter = {})
    records = CacheStore::CACHE.read(self.table_name)
    if records.blank?
      return self.where(filter).to_a
    end
    if filter.key?(:id) || filter.key?("id")
      value = records[filter["id"]] || records[filter[:id]]
      return [value].compact
    end
    return records.values.select{|r| filter.all?{|k, v| r.send(k) == v } }
  end

  def update_cache!
    records = CacheStore::CACHE.read(self.class.table_name)
    if records.present?
      records[self.id] = self
      CacheStore::CACHE.write(self.class.table_name, records)
    end
  end

  def destory_cache!
    records = CacheStore::CACHE.read(self.class.table_name)
    if records.present?
      records.delete("self.id")
      CacheStore::CACHE.write(self.class.table_name, records)
    end
  end

  def self.batch_execution_and_retry(sleep_second: nil)
    begin
      yield
    rescue Exception => e
      logger = ActiveSupport::Logger.new("log/batch_error.log")
      console = ActiveSupport::Logger.new(STDOUT)
      logger.extend ActiveSupport::Logger.broadcast(console)
      message = "error: #{e.to_s}\n #{e.backtrace.join("\n")}\n"
      logger.info(message)
      puts message
      if sleep_second.present?
        sleep sleep_second
      end
      retry
    end
  end
end
