require 'xmlsimple'

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_save do
    update_cache!
  end

  before_destroy do
    destory_cache!
  end

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

  #参考: http://www.mk-mode.com/octopress/2011/10/28/28002050/
  # 定数 ( ベッセル楕円体 ( 旧日本測地系 ) )
  BESSEL_R_X  = 6377397.155000 # 赤道半径
  BESSEL_R_Y  = 6356079.000000 # 極半径

  # 定数 ( GRS80 ( 世界測地系 ) )
  GRS80_R_X   = 6378137.000000 # 赤道半径
  GRS80_R_Y   = 6356752.314140 # 極半径

  # 定数 ( WGS84 ( GPS ) )
  WGS84_R_X   = 6378137.000000 # 赤道半径
  WGS84_R_Y   = 6356752.314245 # 極半径

  def self.calc_distance_by_latlon(latitude1:, longitude1:, latitude2:, longitude2:)
    # 2点の経度の差を計算 ( ラジアン )
    a_x = longitude1 * Math::PI / 180.0 - longitude2 * Math::PI / 180.0

    # 2点の緯度の差を計算 ( ラジアン )
    a_y = latitude1 * Math::PI / 180.0 - latitude2 * Math::PI / 180.0

    # 2点の緯度の平均を計算
    p = (latitude1 * Math::PI / 180.0 + latitude2 * Math::PI / 180.0) / 2.0

    # 離心率を計算
    e = Math::sqrt((GRS80_R_X ** 2 - GRS80_R_Y ** 2) / (GRS80_R_X ** 2).to_f)

    # 子午線・卯酉線曲率半径の分母Wを計算
    w = Math::sqrt(1 - (e ** 2) * ((Math::sin(p)) ** 2))

    # 子午線曲率半径を計算
    m = GRS80_R_X * (1 - e ** 2) / (w ** 3).to_f

    # 卯酉線曲率半径を計算
    n = GRS80_R_X / w.to_f

    # 距離を計算
    d  = (a_y * m) ** 2
    d += (a_x * n * Math.cos(p)) ** 2
    d  = Math::sqrt(d)
    #地球を完全な球とみなさない場合はdの値を返す

    # 地球を完全な球とみなした場合
    # ( 球面三角法 )
    # D = R * acos( sin(y1) * sin(y2) + cos(y1) * cos(y2) * cos(x2-x1) )
    d_1  = Math::sin(latitude1 * Math::PI / 180.0)
    d_1 *= Math::sin(latitude2 * Math::PI / 180.0)
    d_2  = Math::cos(latitude1* Math::PI / 180.0)
    d_2 *= Math::cos(latitude2 * Math::PI / 180.0)
    d_2 *= Math::cos(longitude2 * Math::PI / 180.0 - longitude1　* Math::PI / 180.0)
    d_0  = r_x * Math::acos(d_1 + d_2).to_f
    return d_0
  end
end
