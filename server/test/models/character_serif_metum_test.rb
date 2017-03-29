# == Schema Information
#
# Table name: character_serif_meta
#
#  id                 :integer          not null, primary key
#  character_serif_id :integer          not null
#  title              :string(255)      not null
#  character_name     :string(255)      not null
#  image_metum_id     :integer
#  reply_serif_id     :integer
#
# Indexes
#
#  index_character_serif_meta_on_character_serif_id        (character_serif_id)
#  index_character_serif_meta_on_title_and_character_name  (title,character_name)
#

require 'test_helper'

class CharacterSerifMetumTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
