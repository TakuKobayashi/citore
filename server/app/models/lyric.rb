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

  def self.generate_utanet_taget!
    (1..250000).each do |i|
      from_url = Lyric::UTANET_ROOT_CRAWL_URL + i.to_s + "/"
      url = Addressable::URI.parse(from_url)
      doc = Lyric.request_and_parse_html(url)
      svg_img_path = doc.css('#ipad_kashi').map{|d| d.children.map{|c| c[:src] } }.flatten.first
      if svg_img_path.present?
        url.path = svg_img_path
        CrawlTargetUrl.setting_target!(Lyric.to_s, url.to_s, from_url)
      end
      sleep 0.1
    end
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

  def self.generate_jlyric_taget!
    (1..107).each do |i|
      (1..3000).each do |j|
        from_url = Lyric::JLYRIC_ROOT_URL + "i#{i}p#{j}.html"
        url = Addressable::URI.parse(from_url)
        doc = Lyric.request_and_parse_html(url)
        pathes = doc.css(".title").children.map{|c| c[:href]}.select{|url| url != "/" }.compact
        break if pathes.blank?
        transaction do
          pathes.each do |path|
            url.path = path
            CrawlTargetUrl.setting_target!(Lyric.to_s, url.to_s, from_url)
          end
        end
        sleep 0.1
      end
    end
  end

  def self.generate_by_jlyric(nokogiri_doc)
    text = nokogiri_doc.css("#lyricBody").text
    artist = doc.css("#lyricBlock").children.css("td").text
    words = TweetVoiceSeedDynamo.sanitized(artist)
    music_by = words.split(/(歌:|作詞:|作曲:)/).select{|w| w.strip.present? }
    lyric = Lyric.create!({
      title: origin_doc.css(".prev_pad").try(:text).to_s.strip,
      artist_name: music_by[1].to_s.strip,
      word_by: music_by[3].to_s.strip,
      music_by: music_by[5].to_s.strip,
      body: text
    })
    return lyric
  end
end
