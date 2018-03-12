module Sanitizer
  def self.delete_html_comment(text)
    return text.gsub(/<!--(.*)-->/, "")
  end

  def self.delete_javascript_in_html(text)
    return text.gsub(/<script[^>]+?\/>|<script(.|\s)*?\/script>/, "")
  end

  def self.delete_empty_words(text)
    return text.gsub(/\r|\n|\t/, "")
  end

  def self.scan_japan_address(text)
    return text.scan(/(...??[都道府県])((?:旭川|伊達|石狩|盛岡|奥州|田村|南相馬|那須塩原|東村山|武蔵村山|羽村|十日町|上越|富山|野々市|大町|蒲郡|四日市|姫路|大和郡山|廿日市|下松|岩国|田川|大村)市|.+?郡(?:玉村|大町|.+?)[町村]|.+?市.+?区|.+?[市区町村])(.+)/)
  end

  def self.scan_hash_tags(text)
    return text.scan(/[#＃][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー]+/).map(&:strip)
  end

  def self.delete_sharp(text)
    return text.gsub(/[#＃]/, "")
  end

  def self.search_phone_number(text)
    return text.match(/[0-9]{10,11}|\d{2,4}-\d{2,4}-\d{4}/).to_s
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

  def self.basic_sanitize(text)
    #全角半角をいい感じに整える
    sanitized_word = Charwidth.normalize(text)
    #絵文字を除去
    sanitized_word = sanitized_word.encode('SJIS', 'UTF-8', invalid: :replace, undef: :replace, replace: '').encode('UTF-8')
    # 余分な空欄を除去
    sanitized_word.strip!
    return sanitized_word
  end

  def self.twitter_basic_sanitize(text)
    sanitized_word = self.basic_sanitize(text)
    #返信やハッシュタグを除去
    sanitized_word = sanitized_word.gsub(/[#＃@][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー_]+/, "")
    sanitized_word.strip!
    #リツイートにRTとつける事が多いので、そこの部分は取り除く
    sanitized_word = sanitized_word.gsub(/^RT[;: ]/, "")
    # 余分な空欄を除去
    sanitized_word.strip!
    return sanitized_word
  end
end