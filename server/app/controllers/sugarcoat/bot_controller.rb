require 'line/bot'

class Sugarcoat::BotController < BaseController
  protect_from_forgery

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
        sugarcoated = Sugarcoat::Seed.to_sugarcoat(text).join("")
        voice = VoiceWord.generate_and_upload_voice(nil, ApplicationRecord.reading(sugarcoated), "aoi", VoiceWord::VOICE_S3_SUGARCOAT_FILE_ROOT, "public-read", VoiceWord::SUGARCOAT_VOICE_PARAMS)
        request_content = {
          recipient: {
            id:sender
          },
          message: {
            text: sugarcoated
          }
        }

        request_voice_content = {
          recipient: {
            id:sender
          },
          message: {
            attachment: {
              type: "audio",
              payload: {
                url: "https://taptappun.s3.amazonaws.com/" + VoiceWord::VOICE_S3_SUGARCOAT_FILE_ROOT + voice.file_name
              }
            }
          }
        }

        http_client = http_client = HTTPClient.new
        res = http_client.post(endpoint_uri, request_content.to_json, {'Content-Type' => 'application/json; charset=UTF-8'})
        logger.info res.body
        #http_client = http_client = HTTPClient.new
        #res = http_client.post(endpoint_uri, request_voice_content.to_json, {'Content-Type' => 'application/json; charset=UTF-8'})
        #logger.info res.body
        head(:ok)
      else
        #botの発言
        head(:ok)
      end
    end
  end

  def linebot_callback
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    client = Line::Bot::Client.new {|config|
      config.channel_secret = apiconfig["line_bot"]["sugarcoat"]["channel_secret"]
      config.channel_token = apiconfig["line_bot"]["sugarcoat"]["channel_token"]
    }
    body = request.body.read
    logger.info "-----------------------------------"
    logger.info body
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      render status: 400, json: { message: "BadRequest" }.to_json and return
    end
    events = client.parse_events_from(body)
    logger.info "-----------------------------------"
    logger.info events
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        logger.info "message"
        logger.info "-----------------------------------"
        logger.info event.type
        case event.type
        when Line::Bot::Event::MessageType::Text
          logger.info event.message
          logger.info event['replyToken']
          message = {
            type: 'text',
            text: event.message['text']
          }
          logger.info event["source"]
          user = client.get_profile(event["source"]["userId"])
          logger.info user.body
          res = client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video, Line::Bot::Event::MessageType::Audio
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      when Line::Bot::Event::Follow
      when Line::Bot::Event::Unfollow
      end
    end
    head(:ok)
  end
end
