class HomepageController < ApplicationController
  def index
    @announcements = Homepage::Announcement.last(3)
  end

  def contact
  end

  def product
    @products = Homepage::Product.order("id DESC").page(params[:page]).per(30)
  end

  def profile
  end

  def announcement
    @announcements = Homepage::Announcement.order("id DESC").page(params[:page]).per(30)
  end
end
