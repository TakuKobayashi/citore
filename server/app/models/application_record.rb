class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.request_and_parse_html(url)
    http_client = HTTPClient.new
    response = http_client.get(url, {}, {})
    doc = Nokogiri::HTML.parse(response.body)
    return doc
  end

  def self.basic_sanitize(text)
    #絵文字を除去
    sanitized_word = text.each_char.select{|c| c.bytes.count < 4 }.join('')
    #全角半角をいい感じに整える
    sanitized_word = Charwidth.normalize(sanitized_word)
    
    # 余分な空欄を除去
    sanitized_word.strip!
    return sanitized_word
  end
end
