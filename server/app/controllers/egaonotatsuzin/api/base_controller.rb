class Egaonotatsuzin::Api::BaseController < BaseController
  before_action :find_user

  private
  def find_user
    @user = Egaonotatsuzin::User.find_by(token: params[:token])
    @user.try(:sign_in!)
  end
end