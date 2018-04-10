module ResourceUtility
  def self.download_and_compress_to_zip(zip_filepath:, resources: [])
    filename_hash = {}
    resource_groups = resources.group_by{|resource| resource.directory_name }
    Zip::OutputStream.open(zip_filepath) do |stream|
      resource_groups.each do |directory_name, resources_arr|
        resources_arr.each do |resource|
          response_body = resource.download_resource
          next if response_body.blank?
          if filename_hash[resource.save_filename].nil?
            stream.put_next_entry(resource.directory_name + "/" + resource.save_filename)
          else
            stream.put_next_entry(resource.directory_name + "/" + SecureRandom.hex + File.extname(resource.save_filename))
          end
          stream.print(response_body)
          filename_hash[resource.save_filename] = resource
        end
      end
    end
    return zip_filepath
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