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

  def self.request_and_parse_html(url)
    http_client = HTTPClient.new
    response = http_client.get(url, {}, {})
    doc = Nokogiri::HTML.parse(response.body)
    return doc
  end

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
end
