class FoodForecast::SettingsController < FoodForecast::BaseController
  def input
  end

  def register
    redirect_to food_forecast_root_url
  end
end
