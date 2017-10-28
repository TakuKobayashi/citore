# == Schema Information
#
# Table name: datapool_pdf_page_meta
#
#  id                    :integer          not null, primary key
#  datapool_pdf_metum_id :integer          not null
#  page_number           :integer          default(0), not null
#  extract_image_url     :string(255)
#  text                  :text(65535)
#  options               :text(65535)
#
# Indexes
#
#  pdf_metum_id__and_page_index  (datapool_pdf_metum_id,page_number)
#

require 'test_helper'

class Datapool::PdfPageMetumTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
