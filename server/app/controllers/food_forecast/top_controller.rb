class FoodForecast::TopController < FoodForecast::BaseController
  protect_from_forgery
  before_action :find_login_user, only: [:index]

  def index
    # 天気をとる
    # 天気から飲食店やレシピを引っ張る
  end

  def send_location
    @current_user = FoodForecast::User.find_by(token: params[:token])
    location = @current_user.generate_weather_location!(lat: params[:lat], lon: params[:lon], ipaddress: request.remote_ip)
    restaurants = location.search_and_recommend_spots!
    render :json => {location: location, restaurants: restaurants}
  end

  private
  def find_login_user
    @current_user = FoodForecast::User.find_by(token: cookies[:token])
    if @current_user.blank?
      redirect_to input_food_forecast_settings_url and return
    end
  end
end
