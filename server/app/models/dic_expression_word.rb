# == Schema Information
#
# Table name: categorised_words
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  large_category  :integer          default("large_unknown"), not null
#  medium_category :integer          default("medium_unknown"), not null
#  detail_category :string(255)      not null
#  body            :text(65535)      not null
#  relation_id_csv :text(65535)
#
# Indexes
#
#  word_categories_index  (large_category,medium_category,detail_category)
#

class DicExpressionWord < CategorisedWord
  WEBLIO_DIC_URL = "http://www.weblio.jp/cat/dictionary/jtnhj"

  def self.generate_record!
    host_url = Addressable::URI.parse(DicExpressionWord::WEBLIO_DIC_URL)
    url_docs = DicExpressionWord.request_and_parse_html(host_url.to_s)
    urls = url_docs.css(".mainWL").css("a").map{ |anchor| anchor[:href] }

#    text = nokogiri_doc.css("#lyricBody").text
#    lyric_block = nokogiri_doc.css("#lyricBlock").children
#    artist = lyric_block.css("td").text
#    title = lyric_block.css("h2").text
#    words = Lyric.basic_sanitize(artist)
#    music_by = words.split(/(歌:|作詞:|作曲:)/).select{|w| w.strip.present? }
#    lyric = Lyric.create!({
#      title: title.to_s.strip,
#      artist_name: music_by[1].to_s.strip,
#      word_by: music_by[3].to_s.strip,
#      music_by: music_by[5].to_s.strip,
#      body: text
#    })
#    return lyric
  end
end
