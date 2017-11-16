# == Schema Information
#
# Table name: datapool_audio_elements
#
#  id         :integer          not null, primary key
#  audio_type :string(255)      not null
#  audio_id   :integer          not null
#  category   :integer          default("beats"), not null
#  start      :float(24)        default(0.0), not null
#  duration   :float(24)        default(0.0), not null
#  confidence :float(24)        default(0.0), not null
#  others     :text(65535)
#  options    :text(65535)
#
# Indexes
#
#  datapool_audio_elements_index  (audio_type,audio_id,category)
#

require 'test_helper'

class Datapool::AudioElementTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
