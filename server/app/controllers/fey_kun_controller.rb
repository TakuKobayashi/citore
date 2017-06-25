class FeyKunController < BaseController
  protect_from_forgery

  def report
  end

  def analized
    result = JSON.parse(request.body.read, {:symbolize_names => true})

    logger.info result
    logger.info params

    image = FeyKunAi::InquiryTweetImage.find_by(id: result["image_id"])
    image.output ||= {}
    object_image_name = FeyKunAi::InquiryTweetImage.upload_s3(params[:object_img])
    err_image_name = FeyKunAi::InquiryTweetImage.upload_s3(params[:err_img])
    image.output = image.output.merge(result["result"].merge(object_image_name: object_image_name, err_image_name: err_image_name))
    image.save!
    head(:ok)
  end
end
