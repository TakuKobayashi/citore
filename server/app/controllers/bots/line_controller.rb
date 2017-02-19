require 'line/bot'

class Bots::LineController < BaseController
  protect_from_forgery
  before_action :load_line_bot_client
  before_action :received_user_events

  def sugarcoat
    @events.each do |event|
      case event
      when Line::Bot::Event::Message
        line_user_id = event["source"]["userId"]
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
          File.open(Rails.root.to_s +"/tmp/" + SecureRandom.hex, 'wb'){|f| f.write(response.body) }
        end
      when Line::Bot::Event::Follow
        Sugarcoat::LinebotFollowerUser.generate_profile!(line_client: @client, line_user_id: event["source"]["userId"], isfollow: true)
      when Line::Bot::Event::Unfollow
        Sugarcoat::LinebotFollowerUser.generate_profile!(line_client: @client, line_user_id: event["source"]["userId"], isfollow: false)
      end
    end
    head(:ok)
  end

  def citore
    head(:ok)
  end

  def spotgacha
    head(:ok)
  end

  def job_with_life
    head(:ok)
  end

  def shiritori
    head(:ok)
  end

  private
  def load_line_bot_client
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    @client = Line::Bot::Client.new {|config|
      config.channel_secret = apiconfig["line_bot"][params[:action]]["channel_secret"]
      config.channel_token = apiconfig["line_bot"][params[:action]]["channel_token"]
    }
  end

  def received_user_events
    body = request.body.read
    logger.info "-----------------------------------"
    logger.info body
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      render status: 400, json: { message: "BadRequest" }.to_json and return
    end
    @events = @client.parse_events_from(body)
    logger.info "-----------------------------------"
    logger.info @events
  end
end
