require 'google/apis/youtube_v3'

namespace :batch do
  task db_dump_and_upload: :environment do
    cmd = nil 
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    tables = [
      "appear_words",
      "twitter_words",
      "twitter_word_appears",
      "lyrics",
      "crawl_target_urls",
      "wikipedia_pages",
      "wikipedia_topic_categories",
      "wikipedia_articles",
      "youtube_videos",
      "youtube_categories",
      "youtube_channels",
      "youtube_comments",
      "youtube_video_relateds",
      "youtube_video_tags"
    ]
    now_str = Time.now.strftime("%Y%m%d_%H%M%S")
    dir_path = Rails.root.to_s + "/tmp/dbdump/" + now_str
    system("mkdir #{dir_path}")
    tables.each do |table|
      cmd = "mysqldump -u #{configuration['username']} "
      if configuration['password'].present?
        cmd += "--password=#{configuration['password']} "
      end
      cmd += "--skip-lock-tables -t #{configuration['database']} #{table} > #{dir_path}/#{table}.sql"
      system(cmd)
      puts "#{table} dump complete"
    end

    puts "compress start"
    Zip::File.open(dir_path + ".zip", Zip::File::CREATE) do |zip|
      # (1) ZIP内にディレクトリを作成
      zip.mkdir now_str

      tables.each do |table|
        File.open(dir_path + "/" + table + ".sql", 'rb') do |file|
          file.each_line do |line|
            # (2) 作ったディレクトリにファイルを書き込む１
            zip.get_output_stream(now_str + "/#{table}.sql" ) do |s|
              s.print(line)
            end
          end
          puts "#{table} compressed complete"
        end
      end
    end
    puts "compress completed"
    system("rm -r " + dir_path)
    puts "upload start"
    s3 = Aws::S3::Client.new
    File.open(dir_path + ".zip", 'rb') do |zip_file|
      s3.put_object(bucket: "taptappun",body: zip_file,key: "project/sugarcoat/dbdump/#{now_str}.zip", acl: "public-read")
    end
    puts "upload completed"
    system("rm " + dir_path + ".zip")
    puts "batch completed"
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
