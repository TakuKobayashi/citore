class FeyKunController < BaseController
  protect_from_forgery
  layout "fey_kun_layout"

  def report
    @tweet = FeyKunAi::InquiryTweet.find_by(id: params[:id])
  end

  def analized
    image = FeyKunAi::InquiryTweetImage.find_by(id: params[:image_id])
    image.output ||= {}
    image.output = image.output.merge(JSON.parse(params[:result])

    rest_client = FeyKunAi::InquiryTweetImage.get_twitter_rest_client
    err_rep_tweet = rest_client.update_with_media("@#{image.reply_to_tweet.twitter_user_name}\nFey-kun Analysis Result (1/2):\nNoise Ratio:" + image.output["error_ratio"].to_s, params[:error_img])
    object_rep_tweet = rest_client.update_with_media("@#{image.reply_to_tweet.twitter_user_name}\nFey-kun Analysis Result (2/2):\nCaption:" + image.output["error_ratio"].to_s, params[:object_img])

    err_image_urls = FeyKunAi::InquiryTweetImage.get_image_urls_from_tweet(tweet: err_rep_tweet)
    obj_image_urls = FeyKunAi::InquiryTweetImage.get_image_urls_from_tweet(tweet: object_rep_tweet)
    image.output = image.output.merge(object_image_url: obj_image_urls.first, err_image_url: err_image_urls.first)
    image.update!(state: :complete, reply_to_tweet_id: nil)
    head(:ok)
  end
end
