class SnsController < BaseController
  def admin_index
  end

  def oauth_callback
    auth = request.env['omniauth.auth']
    logger.info auth
#    ExtraInfo.update({"#{auth.provider}_#{auth['uid']}" => {screen_name: auth['info']['nickname'], token: auth.credentials.token, token_secret: auth.credentials.secret}})
    if session["redirect_url"].present?
      redirect_to session["redirect_url"]
    else
      redirect_to root_url
    end
  end
end
