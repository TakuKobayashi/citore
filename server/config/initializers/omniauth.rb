Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV.fetch('TWITTER_CITORE_CONSUMER_KEY', ''), ENV.fetch('TWITTER_CITORE_CONSUMER_SECRET', '')
  provider :spotify, ENV.fetch('SPOTIFY_CLIENT_ID', ''), ENV.fetch('SPOTIFY_CLIENT_SECRET', ''), scope: 'playlist-read-private user-read-private user-read-email'
  provider :google_oauth2, ENV.fetch('GOOGLE_OAUTH_CLIENT_ID', ''), ENV.fetch('GOOGLE_OAUTH_CLIENT_SECRET', ''), access_type: "offline", prompt: "consent"
end
