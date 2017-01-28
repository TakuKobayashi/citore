class MoiVoice::OauthController < BaseController
  def twitcas_auth
    redirect_to(MoiVoice::TwitcasUser.get_oauth_url)
  end

  def twitcas_callback
    user = MoiVoice::TwitcasUser.oauth!(params[:code], twitcas_callback_moi_voice_oauth_url)
    redirect_to(play_moi_voice_streaming_path(user_id: user.id))
  end
end
