class Unibo::TalkController < BaseController
  def index
  end

  def input
  end

  def say
    data = Datapool::HatsugenKomachi.find_by(id: rand(Datapool::HatsugenKomachi.count) + 1)
    render :json => data.try(:title)
  end
end
