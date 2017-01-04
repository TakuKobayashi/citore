# == Schema Information
#
# Table name: ngram_words
#
#  id         :integer          not null, primary key
#  from_type  :string(255)      not null
#  from_id    :integer          not null
#  bigram     :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_ngram_words_on_bigram  (bigram)
#  ngeam_from_indexes           (from_type,from_id)
#

require 'test_helper'

class NgramWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
