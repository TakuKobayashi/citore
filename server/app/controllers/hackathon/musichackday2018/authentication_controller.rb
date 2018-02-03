class Hackathon::Musichackday2018::AuthenticationController < BaseController
  layout false
  protect_from_forgery

  def signin
    token = params[:token]
    if token.blank?
      token = SecureRandom.hex
    end
    user = Hackathon::Musichackday2018::User.find_or_initialize_by(token: token)
    if user.new_record?
      user.user_agent = request.user_agent
    end
    user.sign_in!
    session["user_id"] = user.id
    session["user_type"] = user.class.to_s
    session["redirect_url"] = callback_hackathon_musichackday2018_authentication_url
    redirect_to "/auth/spotify"
  end

  def callback
    @user = session["user_type"].constantize.find_by(id: session["user_id"])
    session.delete("user_id")
    session.delete("user_type")
  end
end
