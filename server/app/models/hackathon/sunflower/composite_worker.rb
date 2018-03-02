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
      worker = Hackathon::Sunflower::CompositeWorker.create!(category: :ferry, state: :ready)
      ferry_image_count = ferry_images.count

      ferry_image_sample = MiniMagick::Image.open(ferry_images.first.url)
      base_image = MiniMagick::Image.open(Rails.root.to_s + "/data/sunflower/alpha_base.png")
      base_image_area = base_image.width * base_image.height
      cell_image_area = base_image_area.to_f / ferry_image_count.to_f

      row_count = 0
      cell_line_width = 0
      ferry_images.each_with_index do |ferry_image, index|
        ferry_image_cell = MiniMagick::Image.open(ferry_image.url)
        ferry_image_area = ferry_image_cell.width * ferry_image_cell.height
        ferry_image_scale = ferry_image_area.to_f / cell_image_area.to_f

        resized_width = (ferry_image_cell.width * ferry_image_scale).to_i
        resized_height = (ferry_image_cell.height * ferry_image_scale).to_i
        ferry_image_cell.resize("#{resized_width}x#{resized_height}")

        if (cell_line_width + resized_width) > base_image.width
          cell_line_width = 0
          row_count += 1
        end
        base_image = base_image.composite(ferry_image_cell) do |c|
          c.compose "Over"
          c.geometry "+#{cell_line_width}+#{row_count * ferry_image_cell.height}"
        end
        cell_line_width += resized_width
      end

      base_image.combine_options do |mogrify|
        mogrify.alpha 'on'
        mogrify.channel 'a'
        mogrify.evaluate 'set', '50%'
      end

      bg_image = Hackathon::Sunflower::ImageResource.background.last
      if bg_image.present?
        bg = MiniMagick::Image.open(bg_image.url)
        base_image = bg.composite(base_image) do |c|
          c.compose "Over"
          c.geometry "+0+0"
        end
      end

      post_card_composite_image = worker.composite_postcard(base_image)
      worker.upload_compoleted_routine!(post_card_composite_image)
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

=begin
    twilio_client = Twilio::REST::Client.new(ENV.fetch('TWILIO_PROMO387_ACCOUNT_SID', ''), ENV.fetch('TWILIO_PROMO387_AUTHTOKEN', ''))
    twilio_client.api.account.messages.create(
      from: ENV.fetch('TWILIO_PROMO387_PHONE_NUMBER', ''),
      to: '+TEL',
      body: '写真ができました。こちらからが確認いただけます ' + export_url
    )
=end
  end
end
