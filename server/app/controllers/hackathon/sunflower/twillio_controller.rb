class Hackathon::Sunflower::TwillioController < BaseController
  #user情報と電話番号からSMSを送るためのバッチを登録する
  def reserve
    user = Hackathon::Sunflower::User.find_by(phone_number: params[:phone_number])
    if user.blank?
      user = Hackathon::Sunflower::User.create(token: SecureRandom.hex, name: params[:name], phone_number: params[:phone_number])
    end
    render :json => {user_token: user.token}
  end
end
