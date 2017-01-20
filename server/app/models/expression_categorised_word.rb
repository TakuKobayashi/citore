# == Schema Information
#
# Table name: categorised_words
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  large_category  :integer          not null
#  medium_category :string(255)      not null
#  detail_category :string(255)      not null
#  degree          :integer          default("unknown"), not null
#  body            :string(255)      not null
#  from_url        :string(255)
#
# Indexes
#
#  index_categorised_words_on_from_url  (from_url)
#  word_categories_index                (large_category,medium_category,detail_category)
#

class ExpressionCategorisedWord < CategorisedWord
  JAPANESE_HYOGEN_URL = "http://hyogen.info/"

  def self.generate_taget!
    url = Addressable::URI.parse(ExpressionCategorisedWord::JAPANESE_HYOGEN_URL)
    urls = ExpressionCategorisedWord.request_and_get_links_from_html(url).select{|u| u.include?(url.to_s + "/cate/") }
    break if urls.blank?
    transaction do
      urls.each do |u|
        CrawlTargetUrl.setting_target!(CategorisedWord.to_s, u.to_s, url.to_s)
        sleep 0.1
      end
    end
  end
end
