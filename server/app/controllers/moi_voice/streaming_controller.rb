class MoiVoice::StreamingController < BaseController
  protect_from_forgery
  layout "moi_voice"

  def play
    @twitcast_user = MoiVoice::TwitcasUser.find_by(id: params[:user_id])
    load_or_create
  end

  def hook
    payload = JSON.parse(params[:payload])
    @twitcast_user = MoiVoice::TwitcasUser.find_by(twitcast_uesr_screen_id: payload["userid"])
    live_straem = load_or_create
    if payload["action"] == "live_start"
      live_straem.update!(state: MoiVoice::LiveStream.states[:playing], started_at: Time.now)
    elsif payload["action"] == "live_end"
      live_straem.update!(state: MoiVoice::LiveStream.states[:finish], started_at: Time.now)
    end
    head(:ok)
  end

  private
  def load_or_create
    live_straem = @twitcast_user.live_straems.find_by(state: [MoiVoice::LiveStream.states[:stay], MoiVoice::LiveStream.states[:playing]])
    if live_straem.blank?
      live_straem = twitcast_user.live_straems.create(state: MoiVoice::LiveStream.states[:stay])
    end
    return live_straem
  end
end
