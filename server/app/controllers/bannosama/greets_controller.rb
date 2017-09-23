class Bannosama::GreetsController < Bannosama::BaseController
  def receive
    render :json => params
  end
end
