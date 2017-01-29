# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class StreamingChannel < ApplicationCable::Channel
  def subscribed
    logger.info "subsclibed"
    logger.info params[:stream_id]
    # stream_from "some_channel"
  end

  def unsubscribed
  	logger.info "unsubsclibed"
    # Any cleanup needed when channel is unsubscribed
  end
end
