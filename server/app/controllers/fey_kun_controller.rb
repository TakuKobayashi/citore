class FeyKunController < BaseController
  protect_from_forgery
  layout "fey_kun_layout"

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

    [[image.s3_error_file_url, "error_ratio"], [image.s3_object_file_url, "caption"]].each_with_index do |url_key, index|
      open(url_key[0]) do |tmp|
        rest_client.update_with_media("@#{image.tweet.twitter_user_name}\n#{image.tweet_text(url_key[1], index + 1)}", tmp, {in_reply_to_status_id: image.tweet.tweet_id})
      end
    end
    head(:ok)
  end
end