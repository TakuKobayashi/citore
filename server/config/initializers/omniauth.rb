#OmniAuth.config.full_host = "https://taptappun.net"

api_config = YAML.load(File.read("#{Rails.root.to_s}/config/apiconfig.yml"))
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, api_config["twitter"]["consumer_key"], api_config["twitter"]["consumer_secret"]
  provider :instagram, api_config["instagram"]["client_id"], api_config["instagram"]["client_secret"], scope: 'basic+media+public_content+follower_list+comments+relationships+likes'
end