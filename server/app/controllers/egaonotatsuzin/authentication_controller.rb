class Egaonotatsuzin::AuthenticationController < BaseController
  def spotify
    redirect_to "/auth/spotify"
  end
end
