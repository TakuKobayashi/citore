# == Schema Information
#
# Table name: datapool_hatsugen_komachi_keywords
#
#  id                           :bigint(8)        not null, primary key
#  datapool_hatsugen_komachi_id :integer          not null
#  word                         :string(255)      not null
#  part                         :string(255)      not null
#  appear_score                 :float(24)        default(0.0), not null
#  tf_idf_score                 :float(24)        default(0.0), not null
#
# Indexes
#
#  keywords_hatsugen_komachi_unique_index     (datapool_hatsugen_komachi_id,word,part)
#  keywords_hatsugen_komachi_word_part_index  (word,part)
#

class Datapool::HatsugenKomachiKeyword < ApplicationRecord
  belongs_to :hatsugen_komachi, class_name: 'Datapool::HatsugenKomachi', foreign_key: :datapool_hatsugen_komachi_id, required: false
end
