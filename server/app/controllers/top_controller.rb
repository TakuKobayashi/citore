class TopController < BaseController
  def index
    @products = Homepage::Product.order("id DESC").limit(8)
    @articles = Homepage::Article.order("pubulish_at DESC").limit(3)
  end
end
