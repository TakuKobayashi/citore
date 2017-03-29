# == Schema Information
#
# Table name: image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)      not null
#  title             :string(255)      not null
#  original_filename :string(255)
#  filename          :string(255)
#  url               :string(255)
#
# Indexes
#
#  index_image_meta_on_title  (title)
#  index_image_meta_on_type   (type)
#

require 'test_helper'

class Citore::EroticImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
