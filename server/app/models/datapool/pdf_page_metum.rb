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

class Datapool::PdfPageMetum < ApplicationRecord
  serialize :options, JSON
  belongs_to :pgf_metum, class_name: 'Datapool::PdfMetum', foreign_key: :datapool_pdf_metum_id, required: false
end
