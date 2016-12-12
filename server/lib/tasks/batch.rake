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
    save_file_root_path = "tmp"
    category_sql_gz_file_name = "jawiki-latest-category.sql.gz"
    category_sql_file_name = category_sql_gz_file_name.gsub(".gz", "")
    root_url = "https://dumps.wikimedia.org/jawiki/latest/"
    http_client = HTTPClient.new
    response = http_client.get_content(root_url + category_sql_gz_file_name, {}, {})
    File.open([save_file_root_path, category_sql_gz_file_name].join("/"), 'wb'){|f| f.write(response) }
    gzfile = File.open([save_file_root_path, category_sql_gz_file_name].join("/"), "r")
    File.open([save_file_root_path, category_sql_file_name].join("/"), 'wb'){|f|
      Zlib::GzipReader.wrap(gzfile){|gz|
        sanitized = gz.read.gsub("cat_", "").gsub("`category`", "`" + WikipediaTopicCategory.table_name + "`").force_encoding("utf-8")
        f.write(sanitized)
      }
    }
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    cmd = "mysql -u #{configuration['username']} "
    if configuration['password'].present?
      cmd += "--opt --password=#{configuration['password']} "
    end
    cmd += "-t #{configuration['database']} < #{[save_file_root_path, category_sql_file_name].join("/")}"
    system(cmd)
    system("rm #{[save_file_root_path, category_sql_gz_file_name].join("/")}")
    system("rm #{[save_file_root_path, category_sql_file_name].join("/")}")
  end
end
