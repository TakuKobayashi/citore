class Bannosama::GreetsController < Bannosama::BaseController
  def list
    greets = Bannosama::Greet.all
    render :json => greets.map{|g| {id: g.id, theme: g.theme, thumbnail_url: "https://s3-ap-northeast-1.amazonaws.com/taptappun/project/bannosama/DSC_0001.JPG"} }
  end

  def receive
    greet = Bannosama::Greet.find_by(id: params[:id])
    render :json => {id: greet.try(:id), image_urls: greet.try(:images).try(:pluck, :upload_url) || [], say_comment: greet.try(:message)}
  end
end
