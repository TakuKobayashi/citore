class Hackathon::Arstudio2017::LoaderController < BaseController
  layout false
  protect_from_forgery

  def index
    resources = Hackathon::Arstudio2017::Resource.where(mode: ExtraInfo.read_extra_info["arstudio_mode"].to_i)
    render :layout => false, :json => resources.map{|r| {url: r.url, category: Hackathon::Arstudio2017::Resource.categories[r.category], mode: Hackathon::Arstudio2017::Resource.modes[r.mode]} }
  end

  def upload_admin
    @resources = Hackathon::Arstudio2017::Resource.all
  end

  def switcher_admin
    @current_mode = ExtraInfo.read_extra_info["arstudio_mode"].to_i
  end

  def switch
    mode = params[:mode].to_i
    ExtraInfo.update({"arstudio_mode" => mode})
    redirect_to switcher_admin_hackathon_arstudio2017_loader_url
  end

  def upload
    resource_file = params[:resource_file]
    resource = Hackathon::Arstudio2017::Resource.new(category: params[:category].to_i, mode: params[:mode].to_i)
    resource.upload!(resource_file, resource_file.original_filename)
    redirect_to upload_admin_hackathon_arstudio2017_loader_url
  end

  def remove
    resource = Hackathon::Arstudio2017::Resource.find_by(id: params[:resource_id])
    resource.remove!
    redirect_to upload_admin_hackathon_arstudio2017_loader_url
  end
end
