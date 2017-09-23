class Bannosama::GreetsController < Bannosama::BaseController
  def list
    greets = Bannosama::Greet.all
    render :json => greets.map{|g| {id: g.id, theme: g.theme, thumbnail_url: "https://s3-ap-northeast-1.amazonaws.com/taptappun/project/bannosama/DSC_0001.JPG"} }
  end

  def receive
    render :json => params
  end
end
