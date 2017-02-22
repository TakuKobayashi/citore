# == Schema Information
#
# Table name: linebot_follower_users
#
#  id             :integer          not null, primary key
#  type           :string(255)      not null
#  line_user_id   :string(255)      not null
#  display_name   :string(255)      not null
#  picture_url    :string(255)
#  status_message :text(65535)
#  unfollow       :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_linebot_follower_users_on_line_user_id_and_type  (line_user_id,type) UNIQUE
#

class LinebotFollowerUser < ApplicationRecord
  has_many :events, class_name: 'LinebotEvent', foreign_key: :linebot_follower_user_id

  def self.generate_profile!(line_client: , line_user_id:, isfollow: true)
    follower = self.find_or_initialize_by(type: self.class.base_class.name, line_user_id: line_user_id)
    if follower.new_record?
      response = line_client.get_profile(line_user_id)
      profile = response.body
      follower.display_name = profile["displayName"]
      follower.picture_url = profile["pictureUrl"]
      follower.status_message = profile["statusMessage"]
    end
    if isfollow
      follower.follow!
    else
      follower.unfollow!
    end
    return follower
  end

  def follow!
    update!(unfollow: false)
  end

  def unfollow!
    update!(unfollow: false)
  end

  def generate_event_and_reply!(line_client: , line_event:)
    event = events.new(message_type:line_event.type, line_user_id: event["source"]["userId"])
    case line_event.type
    when Line::Bot::Event::MessageType::Text
      message = {
        type: 'text',
        text: line_event.message['text']
      }
      event.input_text = line_event.message['text']
      line_client.reply_message(event['replyToken'], message)
    when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video, Line::Bot::Event::MessageType::Audio
      response = line_client.get_message_content(line_event.message['id'])
      filepath = Rails.root.to_s +"/tmp/" + SecureRandom.hex
      File.open(filepath, 'wb'){|f| f.write(response.body) }
      event.input_file_path = line_event.filepath
    end
    event.save!
  end
end
