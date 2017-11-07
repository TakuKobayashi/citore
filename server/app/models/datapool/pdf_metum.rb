# == Schema Information
#
# Table name: datapool_pdf_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  query             :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_pdf_meta_on_origin_src  (origin_src)
#  index_datapool_pdf_meta_on_title       (title)
#

class Datapool::PdfMetum < ApplicationRecord
  serialize :options, JSON
  has_many :pages, class_name: 'Datapool::PdfPageMetum', foreign_key: :datapool_pdf_metum_id

  def self.pdffile?(filename)
    return File.extname(filename).downcase == ".pdf"
  end
end
