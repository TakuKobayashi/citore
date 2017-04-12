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
#  from_site_url     :string(255)
#
# Indexes
#
#  index_image_meta_on_from_site_url_and_url           (from_site_url,url) UNIQUE
#  index_image_meta_on_original_filename_and_filename  (original_filename,filename) UNIQUE
#  index_image_meta_on_title                           (title)
#

class FunnyImage < ImageMetum
end
