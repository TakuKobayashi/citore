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

class ImageMetum < ApplicationRecord
  def s3_file_image_root
    return ""
  end

  def s3_file_url
    return "https://taptappun.s3.amazonaws.com/" + self.s3_file_image_root + self.filename
  end

  def file_url
    if self.filename.present?
      return self.s3_file_url
    else
      return self.url
    end
  end

  def save_to_s3!
    if filename.present?
      return false
    end
    http_client = HTTPClient.new
    response = http_client.get_content(self.url, {}, {})

    s3 = Aws::S3::Client.new
    filename = SecureRandom.hex + File.extname(self.url)
    filepath = self.s3_file_image_root + filename
    s3.put_object(bucket: "taptappun",body: response, key: filepath, acl: "public-read")
    self.update!(original_filename: File.basename(self.url), filename: filename)
  end
end
