# == Schema Information
#
# Table name: bannosama_greet_images
#
#  id               :integer          not null, primary key
#  greet_id         :integer          not null
#  origin_file_name :string(255)      not null
#  upload_url       :string(255)      not null
#  score            :float(24)        default(0.0), not null
#  width            :integer          default(0), not null
#  height           :integer          default(0), not null
#  options          :text(65535)
#
# Indexes
#
#  index_bannosama_greet_images_on_greet_id  (greet_id)
#  index_bannosama_greet_images_on_score     (score)
#

class Bannosama::GreetImage < ApplicationRecord
  IMAGE_S3_FILE_ROOT = "project/bannosama/"
  IMAGE_S3_THUMBNAIL_ROOT = "project/bannosama/thumbnail/"

  serialize :options, JSON
  belongs_to :greet, class_name: 'Bannosama::Greet', foreign_key: :greet_id, required: false

  def upload_s3_and_set_metadata(file)
    image = MiniMagick::Image.open(file.path)
    image.resize(Bannosama::GreetImage.calc_resize_text(width: image.width, height: image.height, max_length: 600))
    self.width = image.width
    self.height = image.height
    self.origin_file_name = file.original_filename
    self.options = image.exif
    s3 = Aws::S3::Client.new
    filename = SecureRandom.hex + File.extname(file.original_filename).downcase
    filepath = IMAGE_S3_FILE_ROOT + filename
    s3.put_object(bucket: "taptappun",body: image.to_blob, key: filepath, acl: "public-read")
    self.upload_url = "https://taptappun.s3.amazonaws.com/" + filepath
  end

  def self.calc_resize_text(width:, height:, max_length:)
    if width > height
      resized_width = [width, max_length].min
      resized_height = ((resized_width.to_f / width.to_f) * height.to_f).to_i
      return "#{resized_width.to_i}x#{resized_height.to_i}"
    else
      resized_height = [height, max_length].min
      resized_width = ((resized_height.to_f / height.to_f) * width.to_f).to_i
      return "#{resized_width.to_i}x#{resized_height.to_i}"
    end
  end
end
