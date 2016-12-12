class WikipediaRecord < ApplicationRecord
  self.abstract_class = true

  SAVE_DUMP_FILE_ROOT_PATH = Rails.root.to_s + "/tmp"
  DOWNLOAD_URL = "https://dumps.wikimedia.org/jawiki/latest/"

  def self.download_file(download_file_name)
    savefile_path = [SAVE_DUMP_FILE_ROOT_PATH, download_file_name].join("/")

    http_client = HTTPClient.new
    response = http_client.get_content(DOWNLOAD_URL + download_file_name, {}, {})
    File.open(savefile_path, 'wb'){|f| f.write(response) }
    return savefile_path
  end

  def self.decompress_gz_query_string(gz_file_path)
    result = ""
    gzfile = File.open(gz_file_path, "r")
    Zlib::GzipReader.wrap(gzfile){|gz|
      result = gz.read.to_s.force_encoding("utf-8")
    }
    return result
  end

  def self.import_dump_query(query_file_path)
    environment = Rails.env
    configuration = ActiveRecord::Base.configurations[environment]
    cmd = "mysql -u #{configuration['username']} "
    if configuration['password'].present?
      cmd += "--opt --password=#{configuration['password']} "
    end
    cmd += "-t #{configuration['database']} < #{query_file_path}"
    system(cmd)
  end

  def self.remove_file(file_path)
    system("rm #{file_path}")
  end
end