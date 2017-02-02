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
#  description     :text(65535)
#
# Indexes
#
#  word_categories_index  (large_category,medium_category,detail_category)
#

class ExpressionCategorisedWord < CategorisedWord
  JAPANESE_HYOGEN_URL = "http://hyogen.info"

  def self.generate_target!
    host_url = Addressable::URI.parse(ExpressionCategorisedWord::JAPANESE_HYOGEN_URL)
    urls = ExpressionCategorisedWord.request_and_get_links_from_html(host_url.to_s)
    return if urls.blank?
    transaction do
      urls.each do |url, text|
        next if !url.include?(host_url.to_s + "/cate/")
        link_and_texts = ExpressionCategorisedWord.request_and_get_links_from_html(url)
        link_and_texts.each do |link, t|
          next if !link.include?(host_url.to_s + "/scate/")
          CrawlTargetUrl.setting_target!(ExpressionCategorisedWord.to_s, link.to_s, url.to_s)
        end
      end
    end
  end
end
