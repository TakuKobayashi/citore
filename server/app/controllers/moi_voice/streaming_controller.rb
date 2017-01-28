class MoiVoice::StreamingController < BaseController
  def play
    twitcast_user = MoiVoice::TwitcasUser.find_by(id: params[:user_id])
    logger.info twitcast_user.try(:attributes)
    live_straem = twitcast_user.live_straems.find_or_create_by(state: [MoiVoice::LiveStream.states[:stay], MoiVoice::LiveStream.states[:playing]])
  end
end
