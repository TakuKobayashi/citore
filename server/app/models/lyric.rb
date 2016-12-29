# == Schema Information
#
# Table name: lyrics
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  artist_name :string(255)      not null
#  word_by     :string(255)
#  music_by    :string(255)
#  body        :text(65535)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lyrics_on_artist_name  (artist_name)
#  index_lyrics_on_title        (title)
#

class Lyric < ApplicationRecord
  UTAMAP_ROOT_URL = "http://artists.utamap.com/"
  UTANET_ROOT_CRAWL_URL = "http://www.uta-net.com/song/"
  JOYSOUND_ROOT_URL = "https://www.joysound.com/web/search/song/"
  JLYRIC_ROOT_URL = "http://j-lyric.net/lyric/"

  def self.request_and_scrape_link_filters(url, filter_word)
    doc = request_and_parse_html(url)
    pathes = doc.css('a').map do |anchor|
      if anchor[:href].include?(filter_word)
        nil
      else
        anchor[:href]
      end
    end.uniq.compact
    return pathes
  end

  def self.generate_by_utanet!(origin_url, nokogiri_doc)
    text = nokogiri_doc.css('text').map{|d| d.children.to_s }.join("\n")
    sleep 0.1
    origin_url = Addressable::URI.parse(origin_url)
    origin_doc = Lyric.request_and_parse_html(origin_url)
    artist = origin_doc.css(".kashi_artist").text
    words = TweetVoiceSeedDynamo.sanitized(artist).split("\n").map(&:strip).select{|s| s.present? }
    lyric = Lyric.create!({
      title: origin_doc.css(".prev_pad").try(:text).to_s.strip,
      artist_name: words.detect{|w| w.include?("歌手") }.to_s.split(":")[1].to_s.strip,
      word_by: words.detect{|w| w.include?("作詞") }.to_s.split(":")[1],
      music_by: words.detect{|w| w.include?("作曲") }.to_s.split(":")[1],
      body: text
    })
    return lyric
  end

  def self.generate_by_jlyric(nokogiri_doc)
    doc = ApplicationRecord.request_and_parse_html("http://j-lyric.net/lyric/i1.html")
    doc.css(".title").children.map{|c| c[:href]}.select{|url| url != "/" }.compact
    text = nokogiri_doc.css("#lyricBody").text
    artist = doc.css("#lyricBlock").children.css("td").text
    words = TweetVoiceSeedDynamo.sanitized(artist)
    lyric = Lyric.create!({
      title: origin_doc.css(".prev_pad").try(:text).to_s.strip,
      artist_name: words.detect{|w| w.include?("歌") }.to_s.split(":")[1].to_s.strip,
      word_by: words.detect{|w| w.include?("作詞") }.to_s.split(":")[1],
      music_by: words.detect{|w| w.include?("作曲") }.to_s.split(":")[1],
      body: text
    })
    return lyric
#    doc.css("#lyricBody").text
#    doc.css("#lyricBlock").children.css("td").text
  end
end
