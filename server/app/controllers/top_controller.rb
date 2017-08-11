class TopController < BaseController
  def index
    @products = Homepage::Product.order("id DESC").limit(8)
  end
end
