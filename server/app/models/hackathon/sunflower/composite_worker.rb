# == Schema Information
#
# Table name: hackathon_sunflower_composite_workers
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  export_url :string(255)
#  category   :integer          not null
#  state      :integer          not null
#  options    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  composite_worker_state_category_index  (state,category)
#  composite_worker_user_id_index         (user_id)
#

class Hackathon::Sunflower::CompositeWorker < ApplicationRecord
  serialize :options, JSON
  belongs_to :user, class_name: 'Hackathon::Sunflower::User', foreign_key: :user_id, required: false
  has_many :worker_resources, class_name: 'Hackathon::Sunflower::WorkerResource', foreign_key: :worker_id
  has_many :resources, through: :worker_resources, source: :resource

  enum category: {
    ferry: 0,
    backgraound: 1,
    mixter: 2
  }

  enum state: {
    ready: 0,
    composite: 1,
    complete: 2,
  }

  def self.composite_ferry!
    ferry_images = Hackathon::Sunflower::ImageResource.ferry
    if ferry_images.present?
      if Hackathon::Sunflower::CompositeWorker.where(category: :ferry, state: [:composite, :complete]).exists?
        return false
      end
      worker = Hackathon::Sunflower::CompositeWorker.create!(category: :ferry, state: :ready)
      ferry_image_count = ferry_images.count

      ferry_image_sample = MiniMagick::Image.open(ferry_images.first.url)
      base_image = MiniMagick::Image.open(Rails.root.to_s + "/data/sunflower/alpha_base.png")
      if ferry_image_sample.width < ferry_image_sample.height
        ferry_image_sample.crop("#{ferry_image_sample.width}x#{ferry_image_sample.width}+0+#{(ferry_image_sample.height - ferry_image_sample.width) / 2}")
      else
        ferry_image_sample.crop("#{ferry_image_sample.height}x#{ferry_image_sample.height}+#{(ferry_image_sample.width - ferry_image_sample.height) / 2}+0")
      end
      ferry_image_sample.resize("#{Hackathon::Sunflower::ImageResource::BASE_IMAGE_WIDTH}x#{Hackathon::Sunflower::ImageResource::BASE_IMAGE_HEIGHT}")
      ferry_image_sample.combine_options do |mogrify|
        mogrify.alpha 'on'
        mogrify.channel 'a'
        mogrify.evaluate 'set', '50%'
      end

      composite_image = base_image.composite(ferry_image_sample) do |c|
        c.compose "Over"
        c.geometry "+0+0"
      end
      post_card_composite_image = worker.composite_postcard(composite_image)
      worker.upload_compoleted_routine!(post_card_composite_image)

#      ferry_images.each do |ferry_image|
#        ferry_img = MiniMagick::Image.open(ferry_image.url)

#        worker_resource = worker.worker_resources.new(resource_id: ferry_image.id)
#      end
      return true
    end
    return false
  end

  def composite_postcard(mozic_image)
    post_card_base_image = MiniMagick::Image.open(Rails.root.to_s + "/data/sunflower/postcard_base.png")
    post_card_composite_image = post_card_base_image.composite(mozic_image) do |c|
      c.compose "Over"
      c.geometry "+0+0"
    end
    return post_card_composite_image
  end

  def upload_compoleted_routine!(image)
#   filepath = Hackathon::Sunflower::ImageResource::IMAGE_ROOT_PATH + SecureRandom.hex + ".png"
#   s3 = Aws::S3::Client.new
#    s3.put_object(bucket: "taptappun",body: image.to_blob, key: filepath, acl: "public-read")
#    update!(export_url: ApplicationRecord::S3_ROOT_URL + filepath, state: :complete)
    filepath = Rails.root.to_s + "/tmp/" + SecureRandom.hex + ".png"
    File.open(filepath, "wb"){|f| f.write(image.to_blob) }
    update!(export_url: Rails.root.to_s + filepath, state: :complete)

    api_config = YAML.load(File.read("#{Rails.root.to_s}/config/apiconfig.yml"))
    twilio_client = Twilio::REST::Client.new(api_config["twilio"]["promo387"]["account_sid"], api_config["twilio"]["promo387"]["authtoken"])
    twilio_client.api.account.messages.create(
      from: api_config["twilio"]["promo387"]["phone_number"],
      to: '+818055146460',
      body: '写真ができました。ごちらからが確認いただけます' + export_url
    )
  end
end
