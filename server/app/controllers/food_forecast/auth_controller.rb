class FoodForecast::AuthController < BaseController
  def login
    user = FoodForecast::User.find_by(token: cookie[:token])
    if user.blank?
      redirect_to input_food_forecast_settings_url
    end
    cookie[:token] = user.token
    redirect_to input_food_forecast_root_url
  end

  def logout
    head(:ok)
  end

  def signup
    head(:ok)
  end
end
