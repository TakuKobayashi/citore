class Hackathon::Arstudio2017::LoaderController < BaseController
  layout false

  def index
    resources = Hackathon::Arstudio2017::Resource.all
    render :layout => false, :json => resources.map{|r| {url: r.url, category: Hackathon::Arstudio2017::Resource.categories[r.category] } }
  end

  def upload_admin
    @resources = Hackathon::Arstudio2017::Resource.all
  end

  def upload
    resource_file = params[:resource_file]
    resource = Hackathon::Arstudio2017::Resource.new(category: params[:category].to_i, )
    resource.upload!(resource_file, resource_file.original_filename)
    redirect_to upload_admin_hackathon_arstudio2017_loader_url
  end
end
