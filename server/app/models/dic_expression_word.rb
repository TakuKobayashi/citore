# == Schema Information
#
# Table name: categorised_words
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  large_category  :integer          default("large_unknown"), not null
#  medium_category :string(255)      default(""), not null
#  detail_category :string(255)      not null
#  body            :text(65535)      not null
#  description     :text(65535)
#
# Indexes
#
#  word_categories_index  (large_category,medium_category,detail_category)
#

class DicExpressionWord < CategorisedWord
  WEBLIO_DIC_URL = "http://www.weblio.jp/cat/dictionary/jtnhj"

  def self.generate_record!
    host_url = Addressable::URI.parse(DicExpressionWord::WEBLIO_DIC_URL)
    url_docs = RequestParser.request_and_parse_html(url: host_url.to_s)
    urls = url_docs.css(".mainWL").css("a").map{ |anchor| anchor[:href] }
    urls.each do |url|
      (1...1000).each do |i|
        word_docs = RequestParser.request_and_parse_html(url: url.to_s + "/" + i.to_s)
        docs = word_docs.css(".crosslink").map{|d| {d[:href] => d.text} }
        break if docs.blank?
        docs.each do |doc|
          doc.each do |url, text|
            dc = RequestParser.request_and_parse_html(url: url)
            descriptions = dc.css(".Jtnhj").map{|t| t.text.split("\n").select{|t| t.present? }.last }
            DicExpressionWord.transaction do
              descriptions.each do |des|
                DicExpressionWord.create!(type: DicExpressionWord.to_s, detail_category: "", body: Sanitizer.basic_sanitize(text),description: des)
              end
            end
          end
        end
      end
    end
  end
end
