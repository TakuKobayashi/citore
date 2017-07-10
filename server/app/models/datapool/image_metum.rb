# == Schema Information
#
# Table name: datapool_image_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  original_filename :string(255)
#  src               :string(255)
#  from_url          :string(255)
#
# Indexes
#
#  index_datapool_image_meta_on_from_url_and_src  (from_url,src) UNIQUE
#  index_datapool_image_meta_on_title             (title)
#

class Datapool::ImageMetum < ApplicationRecord
end
