# == Schema Information
#
# Table name: food_forecast_user_periods
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  first_at        :datetime         not null
#  second_at       :datetime         not null
#  third_at        :datetime         not null
#  first_span_day  :float(24)        default(0.0), not null
#  second_span_day :float(24)        default(0.0), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  user_periods_first_at_index    (first_at)
#  user_periods_first_span_index  (first_span_day)
#  user_periods_second_at_index   (second_at)
#  user_periods_user_id_index     (user_id)
#

class FoodForecast::UserPeriod < ApplicationRecord
end
