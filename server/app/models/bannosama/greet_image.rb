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

  serialize :options, JSON
  belongs_to :greet, class_name: 'Bannosama::Greet', foreign_key: :greet_id, required: false

  def upload_s3_and_set_metadata(file)
    fi = FastImage.new(file)
    self.width = fi.size[0]
    self.height = fi.size[1]
    self.origin_file_name = file.original_filename
    s3 = Aws::S3::Client.new
    filename = SecureRandom.hex + File.extname(file.original_filename)
    filepath = IMAGE_S3_FILE_ROOT + filename
    s3.put_object(bucket: "taptappun",body: file.read, key: filepath, acl: "public-read")
    self.upload_url = "https://taptappun.s3.amazonaws.com/" + filepath
  end
end
