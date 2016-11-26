class Sugarcoat::BotController < BaseController
  protect_from_forgery

  def speak
    head(:ok)
  end

  def callback
    case request.method_symbol
    when :get
      if params["hub.verify_token"] == "taptappun"
        render json: params["hub.challenge"]
      else
        render json: "Error, wrong validation token"
      end
    when :post
      apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
      message = params["entry"][0]["messaging"][0]
      if message.include?("message")
        #ユーザーの発言
        sender = message["sender"]["id"]
        text = message["message"]["text"]

        endpoint_uri = "https://graph.facebook.com/v2.6/me/messages?access_token=" + apiconfig["facebook_bot"]["access_token"]
        request_content = {recipient: {id:sender}, message: {text: text}}

        http_client = http_client = HTTPClient.new
        http_client.post(endpoint_uri, request_content, {'Content-Type' => 'application/json; charset=UTF-8'})
      else
        #botの発言
      end
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
