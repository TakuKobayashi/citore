# == Schema Information
#
# Table name: citore_erotic_images
#
#  id                :integer          not null, primary key
#  keyword           :string(255)      not null
#  file_name         :string(255)
#  url               :string(255)
#  preview_file_name :string(255)
#  preview_url       :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_citore_erotic_images_on_keyword  (keyword)
#

class Citore::EroticImage < ApplicationRecord
  IMAGE_S3_FILE_ROOT = "project/citore/images/"

  def s3_file_url
    return "https://taptappun.s3.amazonaws.com/" + Citore::EroticImage::IMAGE_S3_FILE_ROOT + self.file_name
  end

  def file_url
    if self.file_name.present?
      return "https://taptappun.s3.amazonaws.com/" + Citore::EroticImage::IMAGE_S3_FILE_ROOT + self.file_name
    else
      return self.url
    end
  end

  def s3_preview_file_url
    return "https://taptappun.s3.amazonaws.com/" + Citore::EroticImage::IMAGE_S3_FILE_ROOT + self.preview_file_name
  end

  def preview_file_url
    if self.preview_file_name.present?
      return "https://taptappun.s3.amazonaws.com/" + Citore::EroticImage::IMAGE_S3_FILE_ROOT + self.preview_file_name
    else
      return self.preview_url
    end
  end
end
