class Hackathon::Sunflower::ImagesController < BaseController
  protect_from_forgery

  def index
  end

  def upload_ferry
    upload_files = params[:image_files] || []
    upload_files.each do |upload_file|
      image_resource = Hackathon::Sunflower::ImageResource.new(category: :ferry, state: :fix)
      image_resource.upload!(upload_file)
    end
    head(:ok)
  end

  def upload_target
    user = Hackathon::Sunflower::User.find_by(token: params[:token])
    image_resource = Hackathon::Sunflower::ImageResource.find_or_initialize_by(user_id: user.try(:id), category: :background, state: :fix)
    upload_file = params[:target_image]
    image_resource.upload!(upload_file)
    head(:ok)
  end

  def upload_image_resources
    user = Hackathon::Sunflower::User.find_by(token: params[:token])
    upload_files = params[:image_files] || []
    upload_files.each do |upload_file|
      image_resource = Hackathon::Sunflower::ImageResource.new(user_id: user.try(:id), category: :mixter, state: :mutable)
      image_resource.upload!(upload_file)
    end
    head(:ok)
  end
end
