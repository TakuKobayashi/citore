class Hackathon::Musichackday2018::Api::BaseController < BaseController
  before_action :find_user

  private
  def find_user
    @user = Hackathon::Musichackday2018::User.find_by(token: params[:token])
    @user.try(:sign_in!)
  end
end