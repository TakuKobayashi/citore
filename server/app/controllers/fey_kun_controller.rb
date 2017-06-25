class FeyKunController < BaseController
  protect_from_forgery

  def report
  end

  def analized
    image = FeyKunAi::InquiryTweetImage.find_by(id: params[:image_id])
    image.output ||= {}

    object_image_name = FeyKunAi::InquiryTweetImage.upload_s3(params[:object_img])
    err_image_name = FeyKunAi::InquiryTweetImage.upload_s3(params[:error_img])

    image.output = image.output.merge(JSON.parse(params[:result]).merge(object_image_name: object_image_name, err_image_name: err_image_name))
    image.update!(state: :complete)

    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = apiconfig["twitter"]["fey_kun_ai"]["consumer_key"]
      config.consumer_secret     = apiconfig["twitter"]["fey_kun_ai"]["consumer_secret"]
      config.access_token        = apiconfig["twitter"]["fey_kun_ai"]["bot"]["access_token_key"]
      config.access_token_secret = apiconfig["twitter"]["fey_kun_ai"]["bot"]["access_token_secret"]
    end

    rest_client.update_with_media("@#{image.tweet.twitter_user_name}\n#{image.tweet_text}", [image.s3_object_file_url, image.s3_error_file_url], {in_reply_to_status_id: image.tweet.tweet_id})
    head(:ok)
  end
end
