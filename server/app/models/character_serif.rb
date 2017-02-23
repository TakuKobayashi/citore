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

class CharacterSerif < CategorisedWord
  def self.import_serif
    columns = CharacterSerif.column_names
    (1..4).each do |i|
      url = "http://meigen.keiziban-jp.com/anime"
      if i > 1
        url += "/page/" + i.to_s
      end
      doc = ApplicationRecord.request_and_parse_html(url)
      link_list = doc.css("#post_list").css("li.clearfix").css(".title")
      break if link_list.blank?
      link_list.each do |ld|
      	import_list = []
        ld.css("a").each do |lh|
          (1..10).each do |j|
            url2 = lh[:href]
            if j > 1
              url2 += "?wpcrp=" + j.to_s
            end
            puts "#{i}:#{j}:#{url}:#{url2}"
            inner_doc = ApplicationRecord.request_and_parse_html(url2)
            said = inner_doc.css(".header")
            break if said.blank?
            messages = inner_doc.css(".description")
            said.each_with_index do |s, index|
              import_list << CharacterSerif.new(
              	large_category: :large_unknown,
              	medium_category: lh.text.gsub("の名言", ""),
              	detail_category: s.text,
              	body: messages[index].try(:text).to_s
              )
            end
          end
        end
        CharacterSerif.import(import_list)
      end
    end
  end
end