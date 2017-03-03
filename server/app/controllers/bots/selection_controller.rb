class Bots::SelectionController < BaseController

  def spotgacha
    output = Spotgacha::OutputRecommend.find_by!(id: params[:recommend_id])
    output.update!(is_select: true)
    if params[:coupon].present?
      redirect_to output.coupon_url
    else
      redirect_to output.url
    end
  end
end
