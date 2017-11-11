# == Schema Information
#
# Table name: hackathon_arstudio2017_resources
#
#  id                :integer          not null, primary key
#  category          :integer          default("unknown"), not null
#  url               :string(255)      not null
#  original_filename :text(65535)      not null
#  options           :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class Hackathon::Arstudio2017::ResourceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
