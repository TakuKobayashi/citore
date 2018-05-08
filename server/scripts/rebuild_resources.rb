[Datapool::AudioMetum, Datapool::ImageMetum, Datapool::VideoMetum, Datapool::PdfMetum, Datapool::ThreedModelMetum].find_each do |resource|
  aurl = Addressable::URI.parse(resource.src)
  url_parts = aurl.to_s.split("?").select{|url_part| url_part.present? }
  resource.src = url_parts.join("?")
  resource.save!
  if aurl.to_s != resource.src
    puts "changed:" + resource.id.to_s + ": " + aurl.to_s + " to " + resource.src
  end
end

[Datapool::AudioMetum, Datapool::ImageMetum, Datapool::VideoMetum, Datapool::PdfMetum, Datapool::ThreedModelMetum].find_each do |resource|
  src_resources = resource.class.find_origin_src_by_url(url: resource.src)
  uniq_src_resources = src_resources.index_by(&:src)
  src_resources.each do |res|
    if uniq_src_resources.has_key?(res.src)
      uniq_src_resources.delete(res.src)
    else
      puts "destroy:" + res.id.to_s + ": " + res.src
      res.destroy
    end
  end
end

counter = 0
Datapool::ImageMetum.find_in_batches do |images|
  Tempfile.create(SecureRandom.hex) do |tempfile|
    zippath = ResourceUtility.download_and_compress_to_zip(zip_filepath: tempfile.path, resources: images)
    s3 = Aws::S3::Client.new
    filepath = "backup/crawler/images2/" + "#{Time.current.strftime("%Y%m%d_%H%M%S%L")}.zip"
    s3.put_object(bucket: "taptappun",body: File.open(zippath), key: filepath)
  end
  counter = counter + 1
  puts counter.to_s + " completed"
end