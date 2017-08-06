class FoodForecast::SettingsController < FoodForecast::BaseController
  def input
    if cookies[:token].present?
      @current_user = FoodForecast::User.find_by(token: cookies[:token])
    end
  end

  def register
    if params[:token].blank?
      user = FoodForecast::User.create!
      cookies[:token] = user.token
    end
    redirect_to food_forecast_root_url
  end 
end
