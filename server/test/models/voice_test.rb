# == Schema Information
#
# Table name: voices
#
#  id               :integer          not null, primary key
#  seed_type        :string(255)      not null
#  seed_id          :integer          not null
#  speacker_keyword :string(255)      not null
#  speech_file_name :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_voices_on_seed_type_and_seed_id_and_speacker_keyword  (seed_type,seed_id,speacker_keyword) UNIQUE
#

require 'test_helper'

class VoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
