class Homepage::BaseController < BaseController
  before_action :find_visitor

  def find_visitor
    @visitor = Homepage::Access.find_by(uid: cookies[:uid])
  end
end