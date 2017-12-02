class Hackathon::Sunflower::UsersController < BaseController
  def login
    user = Hackathon::Sunflower::User.find_by(token: params[:token])
    if user.blank?
      user = Hackathon::Sunflower::User.find_by(phone_number: params[:phone_number])
    end
    if user.blank?
      user = Hackathon::Sunflower::User.find_by(email: params[:email])
    end
    if user.blank?
      user = Hackathon::Sunflower::User.create(token: SecureRandom.hex, name: params[:name])
    end
    render :json => {user_token: user.token}
  end
end
