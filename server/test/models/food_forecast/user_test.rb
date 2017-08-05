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

require 'test_helper'

class FoodForecast::UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
