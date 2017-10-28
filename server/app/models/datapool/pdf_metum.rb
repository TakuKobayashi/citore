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
end
