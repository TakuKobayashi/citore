# == Schema Information
#
# Table name: bannosama_greets
#
#  id           :integer          not null, primary key
#  from_user_id :integer
#  to_user_id   :integer
#  state        :integer          default("uploaded"), not null
#  message      :text(65535)
#  theme        :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_bannosama_greets_on_from_user_id  (from_user_id)
#  index_bannosama_greets_on_to_user_id    (to_user_id)
#

class Bannosama::Greet < ApplicationRecord
  has_many :images, class_name: 'Bannosama::GreetImage', foreign_key: :greet_id
  belongs_to :to_user, class_name: 'Bannosama::User', foreign_key: :to_user_id, required: false
  belongs_to :from_user, class_name: 'Bannosama::User', foreign_key: :from_user_id, required: false

  enum state: [:uploaded, :received, :checked, :responsed]

  def generate_thumnail!(file)
    return nil if file.blank?
    image = MiniMagick::Image.open(file.path)
    image.resize(Bannosama::GreetImage.calc_resize_text(width: image.width, height: image.height, max_length: 200))
    s3 = Aws::S3::Client.new
    filename = self.id.to_s + File.extname(file.original_filename).downcase
    filepath = Bannosama::GreetImage::IMAGE_S3_THUMBNAIL_ROOT + filename
    s3.put_object(bucket: "taptappun",body: image.to_blob, key: filepath, acl: "public-read")
  end

  def get_thumbnail_url
    image = images.first
    if image.blank?
      return ""
    end
    return "https://taptappun.s3.amazonaws.com/" + Bannosama::GreetImage::IMAGE_S3_THUMBNAIL_ROOT + self.id.to_s + File.extname(image.upload_url).downcase
  end
end
