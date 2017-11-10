class Egaonotatsuzin::BaseController < BaseController
  before_action :find_user

  def find_user
    @user = Egaonotatsuzin::User.find_by(token: token)
  end
end