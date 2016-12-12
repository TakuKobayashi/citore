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
    gz_file_path = WikipediaTopicCategory.download_file("jawiki-latest-category.sql.gz")
    query_string = WikipediaTopicCategory.decompress_gz_query_string(gz_file_path)
    sanitized_query = WikipediaTopicCategory.try(:sanitized_query, query_string) || query_string
    decompressed_file_path = gz_file_path.gsub(".gz", "")
    File.open(decompressed_file_path, 'wb'){|f| f.write(sanitized_query) }
    WikipediaTopicCategory.import_dump_query(decompressed_file_path)
    WikipediaTopicCategory.remove_file(gz_file_path)
    WikipediaTopicCategory.remove_file(decompressed_file_path)
  end
end
