class Tools::TopController < Homepage::BaseController
  def index
    @tools = Homepage::Tool.page(params[:page]).per(10)
  end
end
