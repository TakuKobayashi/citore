class MoiVoice::StreamingController < BaseController
  protect_from_forgery
  layout "moi_voice"

  def play
    twitcast_user = MoiVoice::TwitcasUser.find_by(id: params[:user_id])
    logger.info twitcast_user.try(:attributes)
    live_straem = twitcast_user.live_straems.find_by(state: [MoiVoice::LiveStream.states[:stay], MoiVoice::LiveStream.states[:playing]])
    if live_straem.blank?
      twitcast_user.live_straems.create(state: MoiVoice::LiveStream.states[:stay])
    end
  end

  def hook
    payload = JSON.parse(param[:payload])
    head(:ok)
  end
end
