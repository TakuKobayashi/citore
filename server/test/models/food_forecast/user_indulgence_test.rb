# == Schema Information
#
# Table name: food_forecast_user_indulgences
#
#  id       :integer          not null, primary key
#  user_id  :integer          not null
#  category :integer          default("allergies"), not null
#  word     :string(255)      not null
#
# Indexes
#
#  user_indulgences_user_id_index  (user_id)
#  user_indulgences_word_index     (word)
#

require 'test_helper'

class FoodForecast::UserIndulgenceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
