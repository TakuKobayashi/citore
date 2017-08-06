class FoodForecast::SettingsController < FoodForecast::BaseController
  def input
    if cookies[:token].present?
      @current_user = FoodForecast::User.find_by(token: cookies[:token])
    end
  end

  def register
    if params[:token].present?
      user = FoodForecast::User.find_by!(token: params[:token])
    else
      user = FoodForecast::User.create!
    end
    period =  FoodForecast::UserPeriod.find_or_initialize_by(user_id: user.id)
    if params[:rhythm_first].present?
      period.first_at = Time.parse(params[:rhythm_first])
    else
      period.first_at = Time.current
    end
    period.first_span_day = params[:rhythm_a].to_i * 100 + params[:rhythm_b].to_i * 10 + params[:rhythm_c].to_i
    period.second_at = period.first_at
    period.third_at = period.second_at
    period.second_span_day = period.first_span_day
    period.save!

    cookies[:token] = user.token
    redirect_to food_forecast_root_url
  end
end
