apiconfig = YAML.load(File.open("config/apiconfig.yml"))
http_client = HTTPClient.new
params = {
  username: apiconfig["aitalk"]["username"],
  password: apiconfig["aitalk"]["password"],
  text: "え?マンゴスチン?",
  speaker_name: "nozomi",
  ext: "wav"
}
response = http_client.get_content("http://webapi.aitalk.jp/webapi/v2/ttsget.php", params, {})
open("1_" + SecureRandom.hex + ".wav", 'wb') do |file|
 file.write response 
end