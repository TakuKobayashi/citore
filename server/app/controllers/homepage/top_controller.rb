class Homepage::TopController < Homepage::BaseController
  protect_from_forgery only: [:regist_visitor]

  def index
    @products = Homepage::Product.order("id DESC").limit(8)
    @articles = Homepage::Article.where(active: true).order("pubulish_at DESC").limit(3)
    @tools = Homepage::Tool.order("pubulish_at DESC").limit(3)
#    @tools_pathes = Rails.application.routes.named_routes.helper_names.map(&:to_s).select{|s| s.include?("tools") && s.include?("path") && !s.include?("root") }.
  end

  def regist_visitor
    uid = params[:uid]
    if uid.blank?
      uid = SecureRandom.hex
    end
    @visitor = Homepage::Access.find_or_initialize_by(uid: uid)
    @visitor.update!(user_agent: request.user_agent, ip_address: request.remote_ip)
    render :layout => false, :json => @visitor.to_json({only: [:id, :uid]})
  end
end
