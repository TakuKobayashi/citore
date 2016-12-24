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
      cmd += "-p #{configuration['password']} "
    end
    cmd += "--skip-lock-tables -t #{configuration['database']} #{tables} > #{file_path}"
    system(cmd)
    file = File.open(file_path, 'rb')
    s3 = Aws::S3::Client.new
    s3.put_object(bucket: "taptappun",body: file,key: "project/sugarcoat/dbdump/#{now_str}.sql", acl: "public-read")
    system("rm #{file_path}")
  end

  task update_from_wikipedia: :environment do
    [
        [WikipediaTopicCategory, "jawiki-latest-category.sql.gz"],
        [WikipediaPage, "jawiki-latest-page.sql.gz"], 
        [WikipediaCategoryPage, "jawiki-latest-categorylinks.sql.gz"]
    ].each do |clazz, file_name|
      puts "#{clazz.table_name} download start"
      gz_file_path = clazz.download_file(file_name)
      puts "#{clazz.table_name} decompress start"
      query_string = clazz.decompress_gz_query_string(gz_file_path)
      puts "#{clazz.table_name} save file start"
      sanitized_query = clazz.try(:sanitized_query, query_string) || query_string
      decompressed_file_path = gz_file_path.gsub(".gz", "")
      File.open(decompressed_file_path, 'wb'){|f| f.write(sanitized_query) }
      puts "#{clazz.table_name} import data start"
      clazz.import_dump_query(decompressed_file_path)
      clazz.remove_file(gz_file_path)
      clazz.remove_file(decompressed_file_path)
      puts "#{clazz.table_name} import completed"
    end
  end

  task generate_crawl_target: :environment do
    (1..1000000).each do |i|
      from_url = Lyric::UTANET_ROOT_CRAWL_URL + i.to_s + "/"
      url = Addressable::URI.parse(from_url)
      doc = Lyric.request_and_parse_html(url)
      svg_img_path = doc.css('#ipad_kashi').map{|d| d.children.map{|c| c[:src] } }.flatten.first
      if svg_img_path.present?
        url.path = svg_img_path
        CrawlTargetUrl.setting_target!(Lyric.to_s, url.to_s, from_url)
      end
      sleep 0.1
    end
  end

  task crawl_wikipedia_article: :environment do
    WikipediaArticle.get_article("HTML")
#    Sanitize.clean(hash["query"]["pages"]["9793"]["revisions"].first["*"], Sanitize::Config::RESTRICTED)
  end

  task crawl_lyric_html: :environment do
    CrawlTargetUrl.where(source_type: Lyric.to_s, crawled_at: nil).find_each do |crawl_target|
      url = Addressable::URI.new({host: crawl_target.host,port: crawl_target.port,path: crawl_target.path})
      url.scheme = crawl_target.protocol
      url.query = crawl_target.query
      http_client = HTTPClient.new
      response = http_client.get(url.to_s, {}, {})
      next if response.status.to_i >= 400
      crawl_target.status_code = response.status
      crawl_target.content_type = response.headers["Content-Type"]
      doc = Nokogiri::HTML.parse(response.body)
      text = doc.css('text').map{|d| d.children.to_s }.join("\n")
      sleep 0.1
      origin_url = Addressable::URI.parse(crawl_target.crawl_from_keyword)
      origin_doc = Lyric.request_and_parse_html(origin_url)
      artist = origin_doc.css(".kashi_artist").text
      words = TweetVoiceSeedDynamo.sanitized(artist).split("\n").map(&:strip).select{|s| s.present? }
      Lyric.transaction do
        lyric = Lyric.create!({
          title: origin_doc.css(".prev_pad").try(:text).to_s.strip,
          artist_name: words.detect{|w| w.include?("歌手") }.to_s.split(":")[1].to_s.strip,
          word_by: words.detect{|w| w.include?("作詞") }.to_s.split(":")[1],
          music_by: words.detect{|w| w.include?("作曲") }.to_s.split(":")[1],
          body: text
        })
        crawl_target.source_id = lyric.id
        crawl_target.crawled_at = Time.now
        crawl_target.save!
      end
      sleep 0.1
    end
  end

  task crawl_youtube: :environment do
    apiconfig = YAML.load(File.open(Rails.root.to_s + "/config/apiconfig.yml"))
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = apiconfig["google_api"]["key"]
    response = youtube.list_searches("id,snippet", maxResults: 50)
#    response.items
    p response
  end

  task youtube_download: :environment do
    YoutubeDL.download "https://www.youtube.com/watch?v=0E00Zuayv9Q", output: 'some_file.mp4'
  end
end
