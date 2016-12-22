# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ChatChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from 'chat_channel'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def send_message(data)
    logger.info data
    message = Message.create!(content: data['body'])
    ActionCable.server.broadcast(
      'chat_channel',
      message: render_message(message)
    )
  end
end
