require 'line/bot'

class Bots::LineController < BaseController
  protect_from_forgery
  before_action :load_line_bot_client
  before_action :received_user_events

  def sugarcoat
    each_line_event do |event, line_user|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message_text = line_user.say!(event: event)
          message = {
            type: 'text',
            text: message_text
          }
          @client.reply_message(event['replyToken'], message)
        end
      end
    end
    head(:ok)
  end

  def citore
    each_line_event do |event, line_user|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          answer = line_user.search_and_generate_answer!(event: event)
          message = {
            type: 'text',
            text: answer.output_word
          }
          @client.reply_message(event['replyToken'], message)
          if answer.voice_id.present?
            voice_message = {
              type: 'audio',
              originalContentUrl: answer.voice.s3_file_url,
              duration: 240000
            }
            voice_res = @client.reply_message(event['replyToken'], voice_message)
            logger.info voice_res.code + ":" + voice_res.message + ":" + voice_res.body
          end
          if answer.image_id.present?
            image_message = {
              "type": "image",
              "originalContentUrl": answer.image.file_url,
              "previewImageUrl": answer.image.preview_file_url
            }
            image_res = @client.reply_message(event['replyToken'], image_message)
            logger.info image_res.code + ":" + image_res.message + ":" + image_res.body
          end
        end
      end
    end
    head(:ok)
  end

  def spotgacha
    each_line_event do |event, line_user|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Location
          recommends = line_user.search_and_recommend_spots!(event: event)
          carousels = recommends.map do |recommend|
            actions = [
              {
                type: "uri",
                label: "詳細を見る",
                uri: spotgacha_bots_selection_url(recommend_id: recommend.id)
              }
            ]
            if recommend.phone_number.present?
              actions.insert(0,
                {
                  type: "uri",
                  label: "予約する",
                  uri: "tel:" + recommend.phone_number,
                }
              )
            end
            if recommend.coupon_url.present?
              actions << {
                type: "uri",
                label: "クーポンを使う",
                uri: spotgacha_bots_selection_url(recommend_id: recommend.id, coupon: true)
              }
            end

            {
              thumbnailImageUrl: recommend.image_url,
              title: recommend.place_name,
              text: recommend.place_description,
              actions: actions
            }
          end
          message = {
            type: 'template',
            altText: 'お店の候補はこちら!!',
            template: {
              type: "carousel",
              columns: carousels
            }
          }
          logger.info message
          res = @client.reply_message(event['replyToken'], message)
          logger.info res.code + ":" + res.message + ":" + res.body
        end
      end
    end
    head(:ok)
  end

  def job_with_life
    each_line_event do |event, line_user|
      case event
      when Line::Bot::Event::Beacon
        message_text = line_user.record_and_answer!(event: event)
        message = {
          type: 'text',
          text: message_text
        }
        @client.reply_message(event['replyToken'], message)
      end
    end
    head(:ok)
  end

  def shiritori
    each_line_event do |event, line_user|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message_text = line_user.generate_return_message!(message: event.message['text'])
          message = {
            type: 'text',
            text: message_text
          }
          @client.reply_message(event['replyToken'], message)
        end
      end
    end
    head(:ok)
  end

  def mone
    each_line_event do |event, line_user|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message_text = line_user.say!(event: event)
          message = {
            type: 'text',
            text: message_text
          }
          @client.reply_message(event['replyToken'], message)
        end
      end
    end
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
    unless @client.validate_signature(body, signature)
      render status: 400, json: { message: "BadRequest" }.to_json and return
    end
    @events = @client.parse_events_from(body)
    logger.info "-----------------------------------"
    logger.info @events
  end

  def each_line_event(&block)
    route_action_name = params[:action]
    @events.each do |event|
      case event
      when Line::Bot::Event::Follow
        linebot_follower_user = (route_action_name + "/linebot_follower_user").camelize.classify.constantize
        linebot_follower_user.generate_profile!(line_client: @client, line_user_id: event["source"]["userId"], isfollow: true)
      when Line::Bot::Event::Unfollow
        linebot_follower_user = (route_action_name + "/linebot_follower_user").camelize.classify.constantize
        linebot_follower_user.generate_profile!(line_client: @client, line_user_id: event["source"]["userId"], isfollow: false)
      else
        linebot_follower_user = (route_action_name + "/linebot_follower_user").camelize.classify.constantize
        line_user = linebot_follower_user.find_by!(line_user_id: event["source"]["userId"])
        block.call(event, line_user)
      end
    end
  end
end
