# == Schema Information
#
# Table name: hackathon_arstudio2017_resources
#
#  id                :integer          not null, primary key
#  category          :integer          default("unknown"), not null
#  mode              :integer          default("admin"), not null
#  url               :string(255)      not null
#  original_filename :text(65535)      not null
#  options           :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Hackathon::Arstudio2017::Resource < ApplicationRecord
  RESOURCE_ROOT_PATH = "hackathon/arstudio2017/resources"

  enum mode: {
    admin: 0,
    application: 1,
    others: 2,
    others_next: 3
  }

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
    return Datapool::ResourceMetum::S3_ROOT_URL + self.class.s3_file_image_root + self.filename
  end

  def upload!(file, original_filename)
    s3 = Aws::S3::Client.new
    filepath = RESOURCE_ROOT_PATH + "/" + SecureRandom.hex + ".png"

    image = MiniMagick::Image.open(file.path)
    image.format(:png)
    image.resize(Datapool::ImageMetum.calc_resize_text(width: image.width, height: image.height, max_length: 300))
    if image.width * 4.to_f / 3 < image.height
      crop_width = image.width
      crop_height = (image.width * 4.to_f / 3).to_i
    else
      crop_width = image.width * 3.to_f / 4
      crop_height = image.height
    end
    new_image = image.crop("#{crop_width}x#{crop_height}+#{(image.width - crop_width) / 2}+#{(image.height - crop_height) / 2}")
    s3.put_object(bucket: "taptappun",body: new_image.to_blob, key: filepath, acl: "public-read")
    self.original_filename = original_filename
    self.url = Datapool::ResourceMetum::S3_ROOT_URL + filepath
    self.save!
  end

  def remove!
    s3 = Aws::S3::Client.new
    s3.delete_object(bucket: "taptappun", key: self.url.gsub(Datapool::ResourceMetum::S3_ROOT_URL, ""))
    self.destroy
  end
end
