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

  task get_erokotoba: :environment do
    Citore::EroticWord.twitter_crawl({}) do |twitter_client, options|
      tweet_results = twitter_client.user_timeline(Citore::EroticWord::ERO_KOTOBA_BOT, options)
      tweet_results.each do |status|
        next if status.blank?
        sanitaized_word = TwitterRecord.sanitized(status.text)
        without_url_tweet, urls = ApplicationRecord.separate_urls(sanitaized_word)
        TwitterWord.transaction do
          tweet = TwitterWord.create!(
            twitter_user_id: status.user.id.to_s,
            twitter_user_name: status.user.screen_name.to_s,
            twitter_tweet_id: status.id.to_s,
            tweet: without_url_tweet,
            csv_url: urls.join(","),
            tweet_created_at: status.created_at
          )
          Citore::EroticWord.generate_data_and_voice!(sanitaized_word, tweet.id)
        end
      end
      tweet_results
    end
  end

  task sugarcoat_bot_tweet: :environment do
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
#    facebook_sugarcoat = Koala::Facebook::API.new(apiconfig["facebook_bot"]["access_token"])
#    page_token = facebook_sugarcoat.get_page_access_token("346231432435056")
#    facebook_page = Koala::Facebook::API.new(page_token)
    #facebook_page.put_wall_post('post on page wall')
    #facebook_page.put_connections("346231432435056", 'feed', :message => "甘い甘いシュガーコートだお")
  end

  task :export_to_csv_from_dynamodb, :environment do
    Aws.config.update(Rails.application.config_for(:aws).symbolize_keys)
    table_name = ARGV.last
    client = Aws::DynamoDB::Client.new
    start_key = nil
    counter = 0
    CSV.open(Rails.root.to_s + "/tmp/" + table_name + ".csv", "wb") do |csv|
      results = []
      begin
        counter += 1
        results = client.scan(table_name: table_name, limit: 500, exclusive_start_key: start_key)
        results.items.each_with_index do |hash, index|
          if index == 0 && start_key.blank?
            csv << hash.keys
          end
          values = hash.values
          csv << values.map do |v|
            if v.instance_of?(Array) || v.instance_of?(Hash)
              v.to_json
            else
              v.to_s
            end
          end
        end
        puts "#{counter}:#{results.count}:#{results.last_evaluated_key}"
        start_key = results.last_evaluated_key
      end while start_key.present?
    end
    # 空タスク作ってエラーを握りつぶす
    ARGV.slice(1,ARGV.size).each{|v| task v.to_sym do; end}
  end
end
