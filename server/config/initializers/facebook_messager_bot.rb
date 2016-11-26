apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))

Messenger::Bot.config do |config|
  config.access_token = apiconfig["facebook_bot"]["access_token"]
  config.validation_token = apiconfig["facebook_bot"]["validation_token"]
  config.secret_token = apiconfig["facebook_bot"]["secret_token"]
end