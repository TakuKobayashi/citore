# == Schema Information
#
# Table name: markov_trigrams
#
#  id          :integer          not null, primary key
#  source_type :string(255)      not null
#  source_id   :integer          not null
#  first_gram  :string(255)      default(""), not null
#  second_gram :string(255)      default(""), not null
#  third_gram  :string(255)      default(""), not null
#  is_end      :boolean          default(FALSE), not null
#
# Indexes
#
#  index_markov_trigrams_on_source_type_and_source_id  (source_type,source_id)
#  markov_trigram_word_index                           (first_gram,second_gram,third_gram)
#

class MarkovTrigram < ApplicationRecord
end
