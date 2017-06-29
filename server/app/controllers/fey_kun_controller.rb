class FeyKunController < BaseController
  protect_from_forgery
  layout "fey_kun_layout"

  def report
    @tweet = FeyKunAi::InquiryTweet.find_by(id: params[:id])
  end

  def analized
    image = FeyKunAi::InquiryTweetImage.find_by(id: params[:image_id])
    image.output ||= {}

    #TODO twitterにアップしたのならTwitterのURLを見た方がいいような気がする
    object_image_name = FeyKunAi::InquiryTweetImage.upload_s3(params[:object_img])
    err_image_name = FeyKunAi::InquiryTweetImage.upload_s3(params[:error_img])

    image.output = image.output.merge(JSON.parse(params[:result]).merge(object_image_name: object_image_name, err_image_name: err_image_name))

    rest_client = FeyKunAi::InquiryTweetImage.get_twitter_rest_client

    # mediaにはファイルを配列で渡すこともできる
    [[image.s3_error_file_url, "error_ratio"], [image.s3_object_file_url, "caption"]].each_with_index do |url_key, index|
      open(url_key[0]) do |tmp|
        rest_client.update_with_media("@#{image.reply_to_tweet.twitter_user_name}\n#{image.tweet_text(url_key[1], index + 1)}", tmp, {in_reply_to_status_id: image.reply_to_tweet.tweet_id})
      end
    end
    image.update!(state: :complete, reply_to_tweet_id: nil)
    head(:ok)
  end
end
