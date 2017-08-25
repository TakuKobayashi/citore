class Unibo::TalkController < BaseController
  protect_from_forgery

  def index
  end

  def input
  end

  def say
    word = params[:word]
    data = Datapool::HatsugenKomachi.find_by(id: rand(Datapool::HatsugenKomachi.count) + 1)
    render :json => data.try(:title)
  end
end
