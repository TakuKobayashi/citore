module ResourceUtility
  def self.download_and_compress_to_zip(zip_filepath:, resources: [])
    filename_hash = {}
    resource_groups = resources.group_by{|res| res.directory_name }
    content_count = 0
    Zip::OutputStream.open(zip_filepath) do |stream|
      resource_groups.each do |dir_name, resources_arr|
        resources_arr.each do |resource|
          response_body = resource.download_resource
          # blank?だと正規表現チェックしているようで、バイナリデータが必ずしもUTF-8とは限らないのでここではblank?を使わない
          next if response_body.nil? || response_body.empty?
          if filename_hash[resource.save_filename].nil?
            stream.put_next_entry(dir_name + "/" + resource.save_filename)
          else
            stream.put_next_entry(dir_name + "/" + SecureRandom.hex + File.extname(resource.save_filename))
          end
          stream.print(response_body)
          filename_hash[resource.save_filename] = resource
          content_count = content_count+ 1
        end
      end
    end
    if content_count.zero?
      return nil
    else
      return zip_filepath
    end
  end

  def self.crawler_routine!
    Homepage::UploadJobQueue.cleanup!
    Datapool::Website.resource_crawl!
    Datapool::ImageMetum.backup!
  end

  def self.upload_s3(binary, filepath)
    s3 = Aws::S3::Client.new
    s3.put_object(bucket: "taptappun",body: binary, key: filepath, acl: "public-read")
    return filepath
  end
end