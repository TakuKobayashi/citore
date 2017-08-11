class TopController < BaseController
  def index
    @products = Homepage::Product.order("id DESC").limit(8)
    @articles = Homepage::Article.order("pubulish_at DESC").limit(3)
    @tools = Homepage::Tool.order("pubulish_at DESC").limit(3)
#    @tools_pathes = Rails.application.routes.named_routes.helper_names.map(&:to_s).select{|s| s.include?("tools") && s.include?("path") && !s.include?("root") }.
  end
end
