namespace :batch do
  task db_dump_and_upload: :environment do
    cmd = nil 
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    tables = ["tweet_appear_words", "twitter_words", "twitter_word_appears"].join(" ")
    now_str = Time.now.strftime("%Y%m%d_%H%M%S")
    file_path = Rails.root.to_s + "/tmp/dbdump/#{now_str}.sql"
    cmd = "mysqldump -u #{configuration['username']} "
    if configuration['password'].present?
      cmd += "--opt --password=#{configuration['password']} "
    end
    cmd += "-t #{configuration['database']} #{tables} > #{file_path}"
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
    now = Time.now
    (1..1000000).each do |i|
      p (Time.now - now).second
      now = Time.now
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

  task crawl_lyric_html: :environment do

=begin
    doc = Lyric.request_and_parse_html(url.to_s)
    texts = doc.css('text').map{|d| d.children.to_s }.join("\n")
    p texts
=end
  end
end
