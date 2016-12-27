# == Schema Information
#
# Table name: wikipedia_articles
#
#  id                :integer          not null, primary key
#  wikipedia_page_id :integer          default(0), not null
#  title             :string(255)      default(""), not null
#  body              :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_wikipedia_articles_on_title              (title)
#  index_wikipedia_articles_on_wikipedia_page_id  (wikipedia_page_id)
#

class WikipediaArticle < ApplicationRecord
  WIKIPEDIA_API_URL = "https://ja.wikipedia.org/w/api.php"

  def self.get_article(*titles)
    params = {
      format: "json",
      action: "query",
      prop: "revisions",
      rvprop: "content",
      rvparse: true,
      titles: titles.join("|")
    }
    http_client = HTTPClient.new
    response = http_client.get(WIKIPEDIA_API_URL.to_s, params, {})
    return JSON.parse(response.body)
  end

  def self.sanitize(text)
    #絵文字を除去
    sanitized_word = text.each_char.select{|c| c.bytes.count < 4 }.join('')
    #全角半角をいい感じに整える
    sanitized_word = Charwidth.normalize(sanitized_word)
    return sanitized_word
  end
end
