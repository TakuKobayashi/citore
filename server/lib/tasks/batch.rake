require 'google/apis/youtube_v3'

namespace :batch do
  task db_dump_and_upload: :environment do
    cmd = nil 
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    tables = ["tweet_appear_words", "twitter_words", "twitter_word_appears", "lyrics"].join(" ")
    now_str = Time.now.strftime("%Y%m%d_%H%M%S")
    file_path = Rails.root.to_s + "/tmp/dbdump/#{now_str}.sql"
    cmd = "mysqldump -u #{configuration['username']} "
    if configuration['password'].present?
      cmd += "--password=#{configuration['password']} "
    end
    cmd += "--skip-lock-tables -t #{configuration['database']} #{tables} > #{file_path}"
    system(cmd)
    file = File.open(file_path, 'rb')
    s3 = Aws::S3::Client.new
    s3.put_object(bucket: "taptappun",body: file,key: "project/sugarcoat/dbdump/#{now_str}.sql", acl: "public-read")
    system("rm #{file_path}")
  end

  task sugarcoat_bot_tweet: :environment do
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
#    facebook_sugarcoat = Koala::Facebook::API.new(apiconfig["facebook_bot"]["access_token"])
#    page_token = facebook_sugarcoat.get_page_access_token("346231432435056")
#    facebook_page = Koala::Facebook::API.new(page_token)
    #facebook_page.put_wall_post('post on page wall')
    #facebook_page.put_connections("346231432435056", 'feed', :message => "甘い甘いシュガーコートだお")
  end
end
