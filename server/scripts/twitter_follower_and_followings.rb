client = TwitterRecord.get_twitter_rest_client("citore")
follower_ids = client.follower_ids("taptappun").to_a
following_ids = client.friend_ids("taptappun").to_a
begin
  followers = follower_ids.each_slice(100).to_a.inject ([]) do |users, ids|
    users.concat(client.users(ids))
  end
  followings = following_ids.each_slice(100).to_a.inject ([]) do |users, ids|
    users.concat(client.users(ids))
  end
  followers.each_with_index{ |user, i| puts "#{i + 1}: #{user.screen_name}" }
  followings.each_with_index{ |user, i| puts "#{i + 1}: #{user.screen_name}" }

  only_following_ids = following_ids - follower_ids
  only_following_users = followings.select{|fuser| only_following_ids.include?(fuser.id) }
  only_following_users.each_with_index{ |user, i| puts "onlyfollow:#{i + 1}: #{user.screen_name}" }
rescue Twitter::Error::TooManyRequests => error
  puts error.rate_limit.reset_in
  sleep error.rate_limit.reset_in
  retry
end
