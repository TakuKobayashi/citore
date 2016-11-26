class Sugarcoat::BotController < BaseController
  def speak
    head(:ok)
  end

  def callback
    if params["hub.verify_token"] == "taptappun"
      render json: params["hub.challenge"]
    else
      render json: "Error, wrong validation token"
    end
  end
end
