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

  def message(event, sender)
    logger.info "message"
    logger.info event
    logger.info sender
    # profile = sender.get_profile(field) # default field [:locale, :timezone, :gender, :first_name, :last_name, :profile_pic]
    sender.reply({ text: event['message']['text']})
  end

  def delivery(event, sender)
    logger.info "delivery"
    logger.info event
    logger.info sender
  end

  def postback(event, sender)
    logger.info "postback"
    logger.info event
    logger.info sender

    payload = event["postback"]["payload"]
    case payload
    when :something
      #ex) process sender.reply({text: "button click event!"})
    end
  end
end
