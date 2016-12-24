module ExtraInfo
  EXTRA_INFO_FILE_PATH = Rails.root.to_s + "/tmp/extra_info.json"

  def self.read_extra_info
    return {} unless File.exist?(EXTRA_INFO_FILE_PATH)
    return JSON.parse(File.read(EXTRA_INFO_FILE_PATH))
  end

  def self.update(hash = {})
  	new_hash = read_extra_info.merge(hash)
  	File.open(EXTRA_INFO_FILE_PATH, "w"){
      |f| f.write(new_hash.to_json)
    }
    return new_hash
  end
end