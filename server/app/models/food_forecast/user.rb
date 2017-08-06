# == Schema Information
#
# Table name: food_forecast_users
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  token         :string(255)      not null
#  push_token    :text(65535)
#  last_login_at :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_food_forecast_users_on_last_login_at  (last_login_at)
#  index_food_forecast_users_on_token          (token) UNIQUE
#

class FoodForecast::User < ApplicationRecord
  before_create do
    self.last_login_at = Time.current
    self.token = SecureRandom.hex
  end

  has_one :period, class_name: 'FoodForecast::UserPeriod', foreign_key: :user_id, required: false
  has_many :indulgences, class_name: 'FoodForecast::UserIndulgence', foreign_key: :user_id
  has_many :locations, class_name: 'FoodForecast::UserWeatherLocation', foreign_key: :user_id
  has_many :restaurant_outputs, class_name: 'FoodForecast::UserRestaurantOutput', foreign_key: :user_id

  def generate_weather_location!(lat: nil, lon: nil, ipaddress: nil)
    if lat.present? && lon.present?
      latitute = lat.to_f
      longitude = lon.to_f
    else
      latitute = 0
      longitude = 0

      geos = Geocoder.search(ipaddress.to_s)
      geos.each do |geo|
        latitute += geo.latitude
        longitude += geo.longitude
      end
      latitute = latitute / geos.size
      longitude = longitude / geos.size
    end

    location = self.locations.create!(lat: latitute,lon: longitude, ip_address: ipaddress, accessed_at: Time.current)
    location.update_weather_reports!
    return location
  end
end