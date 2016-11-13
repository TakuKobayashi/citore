class BaseController < ApplicationController
  before_action :permit_all_params

  def permit_all_params
    params.permit!
  end
end