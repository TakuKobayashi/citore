require 'xmlsimple'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_save do
    update_cache!
  end

  before_destroy do
    destroy_cache!
  end

  MECAB_NEOLOGD_DIC_PATH = "/usr/local/lib/mecab/dic/mecab-ipadic-neologd"
  S3_ROOT_URL = "https://taptappun.s3.amazonaws.com/"

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

  def destroy_cache!
    records = CacheStore::CACHE.read(self.class.table_name)
    if records.present?
      records.delete(self.id.to_s)
      CacheStore::CACHE.write(self.class.table_name, records)
    end
  end

  def self.batch_execution_and_retry(sleep_second: nil)
    begin
      yield
    rescue RuntimeError => e
      logger = ActiveSupport::Logger.new("log/batch_error.log")
      console = ActiveSupport::Logger.new(STDOUT)
      logger.extend ActiveSupport::Logger.broadcast(console)
      message = "error: #{e.message}\n #{e.backtrace.join("\n")}\n"
      logger.info(message)
      puts message
      if sleep_second.present?
        sleep sleep_second
      end
      retry
    end
  end

  def self.get_location_words(text)
    place_names = []
    natto = ApplicationRecord.get_natto
    natto.parse(text) do |n|
      next if n.surface.blank?
      features = n.feature.split(",")
      if features[1] == "固有名詞" && features[2] == "地域"
        place_names << n.surface
      end
    end
    return place_names
  end

  def self.search_phone_number(text)
    return text.match(/[0-9]{10,11}|\d{2,4}-\d{2,4}-\d{4}/).to_s
  end

  def self.merge_full_url(src:, org:)
    src_url = Addressable::URI.parse(src.to_s.gsub(/(\.\.\/|\.\/)+/,"/"))
    org_url = Addressable::URI.parse(org.to_s)
    pathes = src_url.path.to_s.split("/")
    # 空っぽもありうる
    if pathes.last.try(:include?, "#")
      pathes[pathes.size - 1] = pathes.last.gsub(/#.*/, "")
      src_url.path = pathes.join("/")
    end
    if (src_url.scheme.blank? || src_url.host.blank?)
      if src_url.path.to_s.first != "/"
        org_pathes = org_url.path.to_s.split("/")
        new_pathes = org_pathes[0..(org_pathes.size - 2)] + pathes
        src_url.path = new_pathes.join("/")
      end
    end
    if src_url.scheme.blank?
      src_url.scheme = org_url.scheme.to_s
    end
    if src_url.host.blank?
      src_url.host = org_url.host.to_s
    end
    return src_url
  end
end
