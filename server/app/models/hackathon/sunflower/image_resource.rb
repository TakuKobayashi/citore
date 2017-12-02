# == Schema Information
#
# Table name: hackathon_sunflower_image_resources
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  url        :string(255)      not null
#  category   :integer          default(0), not null
#  state      :integer          not null
#  width      :integer          default(0), not null
#  height     :integer          default(0), not null
#  options    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_hackathon_sunflower_image_resources_on_user_id  (user_id)
#

class Hackathon::Sunflower::ImageResource < ApplicationRecord
  serialize :options, JSON
  belongs_to :user, class_name: 'Hackathon::Sunflower::User', foreign_key: :user_id, required: false
  has_many :worker_resources, class_name: 'Hackathon::Sunflower::WorkerResource', foreign_key: :resource_id
  has_many :workers, through: :worker_resources, source: :worker

  BASE_IMAGE_WIDTH = 1378
  BASE_IMAGE_HEIGHT = 1378

  IMAGE_ROOT_PATH = "hackathon/sunflower/images/"

  enum category: {
    ferry: 0,
    background: 1,
    mixter: 2
  }

  enum state: {
    fix: 0,
    mutable: 1
  }

  def upload!(file)
    image = MiniMagick::Image.open(file.path)
    image.format(:png)
    if background?
      # 正方形になるように真ん中だけ切り抜く
      if image.width < image.height
        image.crop("#{image.width}x#{image.width}+0+#{(image.height - image.width) / 2}")
      else
        image.crop("#{image.height}x#{image.height}+#{(image.width - image.height) / 2}+0")
      end
      image.resize("#{BASE_IMAGE_WIDTH}x#{BASE_IMAGE_HEIGHT}")
    end
    filepath = IMAGE_ROOT_PATH + SecureRandom.hex + ".png"
    s3 = Aws::S3::Client.new
    s3.put_object(bucket: "taptappun",body: image.to_blob, key: filepath, acl: "public-read")
    update!(width: image.width, height: image.height, url: ApplicationRecord::S3_ROOT_URL + filepath)
#    filepath = Rails.root.to_s + "/tmp/" + SecureRandom.hex + ".png"
#    File.open(filepath, "wb"){|f| f.write(image.to_blob) }
#    update!(width: image.width, height: image.height, url: filepath)
  end
end
