class FoodForecast::TopController < FoodForecast::BaseController
  before_action :find_login_user

  def index
    # 天気をとる
    # 天気から飲食店やレシピを引っ張る
  end

  def send_location
    location = @current_user.generate_weather_location!(lat: params[:lat], lon: params[:lon], ipaddress: request.remote_ip)
    render :json => location
  end

  private
  def find_login_user
    @current_user = FoodForecast::User.find_by(token: cookies[:token])
    if @current_user.blank?
      redirect_to input_food_forecast_settings_url and return
    end
  end
end
