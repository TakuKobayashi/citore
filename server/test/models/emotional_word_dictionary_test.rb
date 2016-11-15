# == Schema Information
#
# Table name: emotional_word_dictionaries
#
#  id         :integer          not null, primary key
#  part       :string(255)      not null
#  word       :string(255)      not null
#  reading    :string(255)      not null
#  score      :float(24)        default(0.0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_emotional_word_dictionaries_on_reading  (reading)
#  index_emotional_word_dictionaries_on_word     (word)
#

require 'test_helper'

class EmotionalWordDictionaryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
