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
    doc = RequestParser.request_and_parse_html(url: "http://40s-animeigen.com/sakuhin/")
    link_list = doc.css(".so-panel").css("li.cat-item")
    link_list.css("a").each do |link|
      (1..100).each do |i|
      	url = link[:href]
      	if i > 1
      	  url += "page/#{i}/"
      	end
      	p url
        content_doc = RequestParser.request_and_parse_html(url: url)
        break if content_doc.css("dd").blank?
        import_list = []
        content_doc.css("dd").each do |dd|
          tag_doms = dd.css(".pcone")
          cats = tag_doms[0].css("b").text.split(",")
          tags = tag_doms[1].css("b").text.split(",").map(&:strip)
          import_list << CharacterSerif.new(
            large_category: :large_unknown,
            medium_category: cats[0].to_s.strip,
            detail_category: cats[1].to_s.strip,
            body: dd.css("h3").text.strip,
            description: tags.join(" ")
          )
        end
        CharacterSerif.import(import_list)
      end
    end
  end
end