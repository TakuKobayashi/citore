# == Schema Information
#
# Table name: categorised_words
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  large_category  :integer          default(NULL), not null
#  medium_category :integer          default(NULL), not null
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

class CategorisedWord < ApplicationRecord
  enum large_category: {
    0 => "unknown",
    1 => "感情",
    2 => "感覚",
    3 => "人物",
    4 => "風景",
    5 => "食べ物",
  }

  enum medium_category: {
  	100 => "喜び",
  	101 => "怒り",
  	102 => "悲しみ",
  	103 => "寂しい・喪失感",
  	104 => "恐怖・不安",
  	105 => "恥ずかしい",
  	106 => "好き",
  	107 => "嫌い",
  	108 => "気分が晴れない・落ち込む",
  	109 => "我慢・諦め",
  	110 => "悔やむ",
  	111 => "心が傷つく",
  	112 => "興奮・気持ちが高ぶる",
  	113 => "感動",
  	114 => "緊張",
  	115 => "心が乱れる",
  	116 => "安心する",
  	117 => "驚き",
  	118 => "笑う・笑み",
  	119 => "表情・顔に表れた気持ち",
  	120 => "複雑な気持ち",
  	121 => "その他の気分",
  }

  enum degree: [:unknown, :very_low, :low, :normal, :high, :ver_high]
end
