class SnsController < BaseController
  def admin_index
  end

  def oauth_callback
    auth = request.env['omniauth.auth']
    ExtraInfo.update({"#{auth.provider}_#{auth['uid']}" => {screen_name: auth['info']['nickname'], token: auth.credentials.token, token_secret: auth.credentials.secret}})
    redirect_to admin_index_sns_path
  end
end
