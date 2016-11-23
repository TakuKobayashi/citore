# == Schema Information
#
# Table name: tweet_seeds
#
#  id             :integer          not null, primary key
#  tweet_id_str   :string(255)      not null
#  tweet          :string(255)      not null
#  search_keyword :string(255)      not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_tweet_seeds_on_search_keyword  (search_keyword)
#  index_tweet_seeds_on_tweet_id_str    (tweet_id_str) UNIQUE
#

class TweetSeed < ApplicationRecord
  self.abstract_class = true

  has_many :tweet_voices

  ERO_KOTOBA_BOT = "ero_kotoba_bot"
  AEGIGOE_BOT = "aegigoe_bot"

  def self.sanitized(text)
    #絵文字を除去
    sanitized_word = text.each_char.select{|c| c.bytes.count < 4 }.join('')
    #全角半角をいい感じに整える
    sanitized_word = Charwidth.normalize(sanitized_word)
    #返信やハッシュタグを除去
    sanitized_word = sanitized_word.gsub(/[#＃@][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー_]+/, "")
    # 余分な空欄を除去
    sanitized_word.strip!
    return sanitized_word
  end

  def self.reading(text)
    #記号を除去
    sanitaized_word = text.gsub(/[、。《》「」〔〕・（）［］｛｝！＂＃＄％＆＇＊＋，－．／：；＜＝＞？＠＼＾＿｀｜～￠￡￣\(\)\[\]<>{}]/, "")
    reading_array = []
    natto = Natto::MeCab.new
    natto.parse(sanitaized_word) do |n|
      next if n.surface.blank?
      csv = n.feature.split(",")
      reading = csv[7]
      if reading.blank?
        reading = n.surface
      end
      reading_array << reading
    end
    return reading_array.join("")
  end

  # カッコの中身の文だけ取得
  def self.bracket_split(text)
    return text.scan(/[「\(].+?[」\)]/).map{|t| t[1..(t.size - 2)]}
  end
end
