# == Schema Information
#
# Table name: line_stickers
#
#  id       :integer          not null, primary key
#  stkid    :integer          not null
#  stkpkgid :integer          not null
#  meaning  :string(255)      not null
#  stkver   :integer          not null
#
# Indexes
#
#  index_line_stickers_on_meaning  (meaning)
#  index_line_stickers_on_stkid    (stkid)
#

require 'test_helper'

class LineStickerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
