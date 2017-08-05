class FoodForecast::SettingsController < BaseController
  def input
    head(:ok)
  end

  def register
    redirect_to food_forecast_root_url
  end
end
