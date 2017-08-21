class Tools::TwitterController < Homepage::BaseController
  before_action :load_twitter_client

  def index
  end

  def input_user
  end

  def diff_follow_and_follower
  end

  def remove_followers
  end

  def crawl_user_all_tweet
    max_id = nil
    timeline_count = 200
    all_tweets = []
    tweets = []
    begin
      options = {count: timeline_count, trim_user: true, exclude_replies: true, contributor_details: false, include_rts: false}
      if max_id.present?
        options.merge!({max_id: max_id.to_i - 1})
      end
      begin
        tweets = @twitter_client.user_timeline(params[:twitter_user].to_s, options)
        max_id = tweets.min_by{|t| t.id }.try(:id)
      rescue Twitter::Error::TooManyRequests => error
        tweets = []
        flash[:error] = "twitter apiの利用上限数を超えました。#{error.rate_limit.reset_in.to_i}秒経ってから再度ご利用ください。とりあえず途中まで取得できた情報を送ります。"
        break
      end
      all_tweets << tweets
    end while tweets.size > 0

    if params[:is_file].present?
      download_file_name = Time.current.strftime("%Y%m%d_%H%M%S") + "_tweets.json"
      tempfile = Tempfile.new(download_file_name)
      tempfile.write(all_tweets.to_json)
      tempfile.close
      tempfile.unlink
      send_file tempfile.path, :filename => download_file_name
    else
      render :json => all_tweets.to_json
    end
  end

  private
  def load_twitter_client
    @twitter_client = TwitterRecord.get_twitter_rest_client("citore")
  end
end
