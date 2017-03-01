# == Schema Information
#
# Table name: spotgacha_input_locations
#
#  id              :integer          not null, primary key
#  input_user_type :string(255)      not null
#  input_user_id   :integer          not null
#  latitude        :float(24)        default(0.0), not null
#  longitude       :float(24)        default(0.0), not null
#  address         :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  spotgacha_input_locations_latlon_index  (latitude,longitude)
#  spotgacha_input_locations_user_index    (input_user_type,input_user_id)
#

class Spotgacha::InputLocation < ApplicationRecord
  belongs_to :input_user, polymorphic: true
end
