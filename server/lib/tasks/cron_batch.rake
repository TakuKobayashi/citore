namespace :cron_batch do
  task db_dump_and_upload: :environment do
    cmd = nil
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    database = Regexp.escape(configuration['database'].to_s)
    username = Regexp.escape(configuration['username'].to_s)
    password = Regexp.escape(configuration['password'].to_s)
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
      "youtube_video_tags",
      "citore_erotic_words",
      "citore_aegigoe_words",
      "voice_words",
      "ngram_words",
      "categorised_words",
      "line_stickers",
      "markov_trigram_prefixes",
      "markov_trigram_words"
    ]
    now_str = Time.now.strftime("%Y%m%d_%H%M%S")
    dir_path = Rails.root.to_s + "/tmp/dbdump/" + now_str
    system("mkdir #{dir_path}")
    tables.each do |table|
      cmd = "mysqldump -u #{username} "
      if password.present?
        cmd += "--password=#{password} "
      end
      cmd += "--skip-lock-tables -t #{database} #{table} > #{dir_path}/#{table}.sql"
      system(cmd)
      puts "#{table} dump complete"
    end

=begin
    puts "compress start"
    Zip::OutputStream.open(dir_path + ".zip") do |zos|
      puts 'Creating zip file...'
      tables.each do |table|
        zos.put_next_entry("#{table}.sql")
        File.open(dir_path + "/" + table + ".sql", 'rb') do |file|
          file.each_line do |line|
            zos.puts line
          end
        end
      end
    end
=end
    Zip::File.open(dir_path + ".zip", Zip::File::CREATE) do |zip|
      # (1) ZIP内にディレクトリを作成
      zip.mkdir now_str

      tables.each do |table|
        # (2) 作ったディレクトリにファイルを書き込む１
        File.open(dir_path + "/" + table + ".sql", 'rb') do |file|
          zip.get_output_stream(now_str + "/#{table}.sql" ){|s|
            file.each_line do |line|
              s.write(line)
            end
          }
          puts "#{table} compressed complete"
        end
      end

      zip.get_output_stream(now_str + "/extra_info.json") do |s|
        s.write(ExtraInfo.read_extra_info.to_json)
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

  task tweet_master_csv_upload: :environment do
    cmd = nil
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    now_str = Time.now.strftime("%Y%m%d_%H%M%S")
    dir_path = Rails.root.to_s + "/tmp/tweet_csv/" + now_str + ".zip"

    
    Zip::File.open(dir_path, Zip::File::CREATE) do |zip|
      Dir.glob(Rails.root.to_s + "/tmp/tweet_csv/*") do |dir_file|
        # (2) 作ったディレクトリにファイルを書き込む１
        File.open(dir_file, 'rb') do |file|
          zip.get_output_stream("#{now_str}/#{File.basename(file.path)}"){|s|
            file.each_line do |line|
              s.write(line)
            end
          }
        end
        puts "#{file} compressed complete"
      end
    end

    puts "compress completed"
    s3 = Aws::S3::Client.new
    File.open(dir_path, 'rb') do |zip_file|
      s3.put_object(bucket: "taptappun",body: zip_file,key: "project/sugarcoat/tweet_csv/#{now_str}.zip", acl: "public-read")
    end
    puts "uploaded"
    File.delete(dir_path)
    Dir.glob(Rails.root.to_s + "/tmp/tweet_csv/*") do |dir_file|
      File.delete(dir_file)
    end
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

  task get_erokotoba: :environment do
    Citore::EroticWord.twitter_crawl(prefix_key: Citore::EroticWord::ERO_KOTOBA_BOT) do |twitter_client, options|
      tweet_results = twitter_client.user_timeline(Citore::EroticWord::ERO_KOTOBA_BOT, options)
      Citore::EroticWord.import_tweet!(tweet_results: tweet_results, generate_voice: true)
      tweet_results
    end
    Citore::EroticWord.twitter_crawl(prefix_key: "erokotoba_hash_tag") do |twitter_client, options|
      tweet_results = twitter_client.search("#エロくないけどエロく聞こえる単語", options)
      Citore::EroticWord.import_tweet!(tweet_results: tweet_results, generate_voice: true)
      tweet_results
    end
    Citore::EroticWord.twitter_crawl(prefix_key: Citore::EroticWord::UTIDAMINAKO_BOT) do |twitter_client, options|
      tweet_results = twitter_client.user_timeline(Citore::EroticWord::UTIDAMINAKO_BOT, options)
      tweet_results.select!{|t| t.text.include?("#エロくないけどエロく聞こえる単語") }
      Citore::EroticWord.import_tweet!(tweet_results: tweet_results, generate_voice: true)
      tweet_results
    end
  end
end