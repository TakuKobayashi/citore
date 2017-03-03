# == Schema Information
#
# Table name: spotgacha_output_recommends
#
#  id                 :integer          not null, primary key
#  input_location_id  :integer          not null
#  output_user_type   :string(255)      not null
#  output_user_id     :integer          not null
#  information_type   :string(255)      not null
#  latitude           :float(24)        default(0.0), not null
#  longitude          :float(24)        default(0.0), not null
#  address            :string(255)
#  phone_number       :string(255)
#  place_id           :string(255)      not null
#  place_name         :string(255)      not null
#  place_name_reading :string(255)      not null
#  place_description  :text(65535)      not null
#  url                :string(255)      not null
#  image_url          :string(255)
#  coupon_url         :string(255)
#  recommended_at     :datetime         not null
#  is_select          :boolean          default(FALSE), not null
#  options            :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_spotgacha_output_recommends_on_input_location_id  (input_location_id)
#  index_spotgacha_output_recommends_on_place_id           (place_id)
#  index_spotgacha_output_recommends_on_recommended_at     (recommended_at)
#  spotgacha_output_recommends_latlon_index                (latitude,longitude)
#  spotgacha_output_recommends_user_index                  (output_user_type,output_user_id)
#

class Spotgacha::OutputRecommend < ApplicationRecord
  serialize :options, JSON
  belongs_to :output_user, polymorphic: true
end
