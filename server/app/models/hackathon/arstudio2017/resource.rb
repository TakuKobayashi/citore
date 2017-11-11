# == Schema Information
#
# Table name: hackathon_arstudio2017_resources
#
#  id                :integer          not null, primary key
#  category          :integer          default("unknown"), not null
#  url               :string(255)      not null
#  original_filename :text(65535)      not null
#  options           :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Hackathon::Arstudio2017::Resource < ApplicationRecord
  RESOURCE_ROOT_PATH = "hackathon/arstudio2017/resources"

  enum category: {
    unknown: 0,
    face: 1,
    nose: 2,
    mouse: 3,
    lip: 4,
    eyes: 5,
    left_eye: 6,
    right_eye: 7,
    eyebrows: 8,
    left_eyebrow: 9,
    right_eyebrow: 10,
    ears: 11,
    left_ear: 12,
    right_ear: 13,
    head: 14,
    hair: 15,
  }

  def file_url
    return ApplicationRecord::S3_ROOT_URL + self.class.s3_file_image_root + self.filename
  end

  def upload!(binary, original_filename)
    s3 = Aws::S3::Client.new
    filepath = RESOURCE_ROOT_PATH + SecureRandom.hex + File.extname(original_filename).downcase
    s3.put_object(bucket: "taptappun",body: binary, key: filepath, acl: "public-read")
    self.original_filename = original_filename
    self.url = ApplicationRecord::S3_ROOT_URL + filepath
    self.save!
  end
end
