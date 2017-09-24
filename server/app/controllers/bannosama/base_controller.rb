class Bannosama::BaseController < BaseController
  layout "bannosama"
  before_action :find_user

  def find_user
    @user = Bannosama::User.find_by(uuid: cookies[:uuid])
    if @user.blank?
      @user = Bannosama::User.create(user_agent: request.user_agent)
    end
    cookies[:uuid] = @user.uuid
  end
end
