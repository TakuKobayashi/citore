class Citore::WordsController < BaseController
  def index
    readings = Citore::EroticWord.pluck(:reading)
    render :json => readings
  end
end
