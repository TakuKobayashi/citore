class Bannosama::GreetsController < Bannosama::BaseController
  def list
    greets = Bannosama::Greet.all.includes(:images)
    render :json => greets.map{|g| {id: g.id, theme: g.theme, thumbnail_url: g.get_thumbnail_url} }
  end

  def receive
    greet = Bannosama::Greet.find_by(id: params[:id])
    render :json => {
        id: greet.try(:id),
        image_urls: greet.try(:images).try(:pluck, :upload_url) || [],
        say_comment: greet.try(:message),
        audio_file_url: greet.try(:audio_upload_url),
        theme: greet.try(:theme)
    }
  end

  def mode_change
    # websocketにcallするためのpass
    http = HTTPClient.new
    http.get("http://localhost:3110/bannosama/greets/mode_change", {mode: params[:mode]})
    head(:ok)
  end
end
