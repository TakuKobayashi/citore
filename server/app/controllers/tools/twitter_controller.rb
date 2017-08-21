class Tools::TwitterController < Homepage::BaseController
  before_action :load_twitter_client

  def index
  end

  def input_user
  end

  def only_follower_users
    following_ids = get_all_following_ids(params[:twitter_user].to_s)
    follower_ids = get_all_follower_ids(params[:twitter_user].to_s)
    only_following_ids = follower_ids - following_ids
    @twitter_users = []

    begin
      @twitter_users = only_following_ids.each_slice(100).to_a.inject ([]) do |users, ids|
        users.concat(client.users(ids))
      end
    rescue Twitter::Error::TooManyRequests => error
      flash[:error] = "twitter apiの利用上限数を超えました。#{error.rate_limit.reset_in.to_i}秒経ってから再度ご利用ください。"
    end
  end

  def only_following_users
    following_ids = get_all_following_ids(params[:twitter_user].to_s)
    follower_ids = get_all_follower_ids(params[:twitter_user].to_s)
    only_following_ids = following_ids - follower_ids
    @twitter_users = []

    begin
      @twitter_users = only_following_ids.each_slice(100).to_a.inject ([]) do |users, ids|
        users.concat(client.users(ids))
      end
    rescue Twitter::Error::TooManyRequests => error
      flash[:error] = "twitter apiの利用上限数を超えました。#{error.rate_limit.reset_in.to_i}秒経ってから再度ご利用ください。"
    end
  end

  def followers
    begin
      @twitter_client.follow(params[:follow_twitter_ids])
      flash[:notice] = "followしました"
    rescue Twitter::Error::TooManyRequests => error
      flash[:error] = "twitter apiの利用上限数を超えました。#{error.rate_limit.reset_in.to_i}秒経ってから再度ご利用ください。"
    end
  end

  def remove_followers
    begin
      @twitter_client.unfollow(params[:remove_twitter_ids])
      flash[:notice] = "followをやめました"
    rescue Twitter::Error::TooManyRequests => error
      flash[:error] = "twitter apiの利用上限数を超えました。#{error.rate_limit.reset_in.to_i}秒経ってから再度ご利用ください。"
    end
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
        flash[:error] = "twitter apiの利用上限数を超えました。#{error.rate_limit.reset_in.to_i}秒経ってから再度ご利用ください。"
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

  def get_all_follower_ids(twitter_user)
    all_follower_ids = []
    follower_ids = []
    begin
      options = {count: 5000}
      begin
        follower_ids = client.follower_ids(twitter_user, options).to_a
      rescue Twitter::Error::TooManyRequests => error
        follower_ids = []
        flash[:error] = "twitter apiの利用上限数を超えました。#{error.rate_limit.reset_in.to_i}秒経ってから再度ご利用ください。"
        break
      end
      all_follower_ids << follower_ids
    end while follower_ids.size > 0
    return all_follower_ids.flatten
  end

  def get_all_following_ids(twitter_user)
    all_following_ids = []
    following_ids = []
    begin
      options = {count: 5000}
      begin
        following_ids = client.friend_ids(twitter_user, options).to_a
      rescue Twitter::Error::TooManyRequests => error
        following_ids = []
        flash[:error] = "twitter apiの利用上限数を超えました。#{error.rate_limit.reset_in.to_i}秒経ってから再度ご利用ください。"
        break
      end
      all_following_ids << following_ids
    end while following_ids.size > 0
    return all_following_ids.flatten
  end
end
