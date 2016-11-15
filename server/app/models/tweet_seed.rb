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

  def sanitized(tweet)
    #絵文字を除去
    sanitized_word = tweet.each_char.select{|c| c.bytes.count < 4 }.join('')
    #全角半角をいい感じに整える
    sanitized_word = Charwidth.normalize(sanitized_word)
    #返信やハッシュタグを除去
    sanitized_word = sanitized_word.gsub(/[#＃@][Ａ-Ｚａ-ｚA-Za-z一-鿆0-9０-９ぁ-ヶｦ-ﾟー_]+/, "")
    # 余分な空欄を除去
    sanitized_word.strip!
    tweet = sanitized_word
    # TODO nattoで読みをひらがなに分解して分解した読みデータも保存する
  end
end
