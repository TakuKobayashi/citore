module Homepage
  module GoogleOperation
    extend ActiveSupport::Concern

  private
  def google_oauth(visitor, callback_url)
    if visitor.google.nil?
      session["redirect_url"] = callback_url
      session["user_id"] = visitor.id
      session["user_type"] = visitor.class.to_s
      redirect_to "/auth/google_oauth2" and return
    end
  end
end