# == Schema Information
#
# Table name: citore_voice_words
#
#  id           :integer          not null, primary key
#  word_type    :string(255)      not null
#  word_id      :integer          not null
#  speaker_name :string(255)      not null
#  file_name    :string(255)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  vioce_word_indexes  (word_type,word_id,speaker_name) UNIQUE
#

require 'test_helper'

class Citore::VoiceWordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
