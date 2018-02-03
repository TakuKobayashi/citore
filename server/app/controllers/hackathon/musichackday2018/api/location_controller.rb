class Hackathon::Musichackday2018::Api::LocationController < Hackathon::Musichackday2018::Api::BaseController
  def notify
    render :layout => false, :json => params.dup
  end
end
