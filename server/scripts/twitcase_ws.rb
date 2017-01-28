apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
url = 'wss://' + apiconfig["twitcas"]["client_id"] + ':' + apiconfig["twitcas"]["client_secret"] + '@realtime.twitcasting.tv/lives'

is_open = false
EM.run do
  conn = Faye::WebSocket::Client.new("wss://websocketapisample.herokuapp.com")

  timers = Timers::Group.new 
  conn.on :open do |e|
    puts "connection success."
    timer = timers.every(1) do
      live = MoiVoice::LiveStream.playing.first
      http_client = HTTPClient.new
      request_user_header = {
        'Content-Type' => 'application/json;charset=UTF-8',
        'Authorization' => 'Bearer ' + live.user.access_token
      }
      url = MoiVoice::TwitcasUser::TWITCAS_API_URL_ROOT + "/movies/#{live.video_id}/comments"
      response = http_client.get(url, {}, request_user_header)
      conn.send(response.body)
    end
  end
 
  conn.on :error do |e|
    puts "error occured."
    puts e.message
  end
 
  conn.on :close do |e|
    puts "connection close."
  end
 
  conn.on :message do |msg|
    puts "message receive."
    result = JSON::parse(msg.data.to_s)
    puts result
  end
end
