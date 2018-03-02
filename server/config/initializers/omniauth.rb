Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV.fetch('TWITTER_CITORE_CONSUMER_KEY', ''), ENV.fetch('TWITTER_CITORE_CONSUMER_SECRET', '')
  provider :instagram, ENV.fetch('INSTAGRAM_CLIENT_ID', ''), ENV.fetch('INSTAGRAM_CLIENT_SECRET', ''), scope: 'basic+media+public_content+follower_list+comments+relationships+likes'
  provider :spotify, ENV.fetch('SPOTIFY_CLIENT_ID', ''), ENV.fetch('SPOTIFY_CLIENT_SECRET', ''), scope: 'playlist-read-private user-read-private user-read-email'
end
