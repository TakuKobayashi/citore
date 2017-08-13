class Homepage::ProductsController < Homepage::BaseController
  def index
    @products = Homepage::Product.where("pubulish_at > ?", Time.current).order("pubulish_at DESC").page(params[:page]).per(10)
  end
end
