class WikipediaRecord < ApplicationRecord
  self.abstract_class = true

  SAVE_DUMP_FILE_ROOT_PATH = Rails.root.to_s + "/tmp"
  DOWNLOAD_URL = "https://dumps.wikimedia.org/jawiki/latest/"

  def self.download_dumpdata(download_file_name)
    category_sql_file_name = category_sql_gz_file_name.gsub(".gz", "")
    savefile_path = [SAVE_DUMP_FILE_ROOT_PATH, download_file_name].join("/")

    http_client = HTTPClient.new
    response = http_client.get_content(DOWNLOAD_URL + download_file_name, {}, {})
    File.open(savefile_path, 'wb'){|f| f.write(response) }
    return savefile_path
  end

  def self.decompress_data
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