class SnsController < BaseController
  def admin_index
  end

  def oauth_callback
    auth = request.env['omniauth.auth']
    logger.info auth
#    ExtraInfo.update({"#{auth.provider}_#{auth['uid']}" => {screen_name: auth['info']['nickname'], token: auth.credentials.token, token_secret: auth.credentials.secret}})
    if session["redirect_url"].present?
      if session["user_id"].present? && session["user_type"].present?
        user = session["user_type"].constantize.find_by(id: session["user_id"])
        clazz = Account
        if auth.provider == "spotify"
          clazz = SpotifyAccount
        elsif auth.provider == "google_oauth2"
          clazz = GoogleAccount
        end
        clazz.sign_up!(user: user, omni_auth: auth)
      end
      redirect_to session["redirect_url"]
    else
      redirect_to root_url
    end
  end
end
