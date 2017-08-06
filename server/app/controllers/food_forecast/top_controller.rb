class FoodForecast::TopController < BaseController
  before_action :find_login_user

  def index
    # 天気をとる
    # 天気から飲食店やレシピを引っ張る
    head(:ok)
  end

  private
  def find_login_user
    @current_user = FoodForecast::User.find_by(token: cookies[:token])
    if @current_user.blank?
      redirect_to input_food_forecast_settings_url and return
    end
  end
end
