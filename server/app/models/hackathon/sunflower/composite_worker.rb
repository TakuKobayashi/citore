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
        origin_height = base_image.height
        origin_width = base_image.width * ferry_image_sample.width.to_f / ferry_image_sample.height
        dumplicate_count = (origin_height / origin_width).to_i
      else
        origin_width = base_image.width
        origin_height = base_image.height * ferry_image_sample.height.to_f / ferry_image_sample.width
        dumplicate_count = (origin_width / origin_height).to_i
      end
      if dumplicate_count <= 0
        dumplicate_count = 1
      end

      #1/2乗 ルート2
      cell_count = ((ferry_image_count / dumplicate_count) ** 0.5).to_i

      ferry_images.each_with_index do |ferry_image, index|
        ferry_image_cell = MiniMagick::Image.open(ferry_image.url)
        ferry_image_cell.resize("#{(origin_width / cell_count).to_i}x#{(origin_height / cell_count).to_i}")
        column = index % cell_count
        row = (index / cell_count).to_i
        base_image = base_image.composite(ferry_image_cell) do |c|
          c.compose "Over"
          c.geometry "+#{column * ferry_image_cell.width}+#{row * ferry_image_cell.height}"
        end
      end

      base_image.combine_options do |mogrify|
        mogrify.alpha 'on'
        mogrify.channel 'a'
        mogrify.evaluate 'set', '50%'
      end

      post_card_composite_image = worker.composite_postcard(base_image)
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
   filepath = Hackathon::Sunflower::ImageResource::IMAGE_ROOT_PATH + SecureRandom.hex + ".png"
   s3 = Aws::S3::Client.new
   s3.put_object(bucket: "taptappun",body: image.to_blob, key: filepath, acl: "public-read")
   update!(export_url: ApplicationRecord::S3_ROOT_URL + filepath, state: :complete)
#    filepath = Rails.root.to_s + "/tmp/" + SecureRandom.hex + ".png"
#    File.open(filepath, "wb"){|f| f.write(image.to_blob) }
#    update!(export_url: Rails.root.to_s + filepath, state: :complete)

    api_config = YAML.load(File.read("#{Rails.root.to_s}/config/apiconfig.yml"))
    twilio_client = Twilio::REST::Client.new(api_config["twilio"]["promo387"]["account_sid"], api_config["twilio"]["promo387"]["authtoken"])
    twilio_client.api.account.messages.create(
      from: api_config["twilio"]["promo387"]["phone_number"],
      to: '+818055146460',
      body: '写真ができました。ごちらからが確認いただけます' + export_url
    )
  end
end
