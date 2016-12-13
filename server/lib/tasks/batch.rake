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
    [[WikipediaTopicCategory, "jawiki-latest-category.sql.gz"],[WikipediaPage, "jawiki-latest-page.sql.gz"]].each do |clazz, file_name|
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
end
