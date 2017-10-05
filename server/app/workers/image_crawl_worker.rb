class ImageCrawlWorker
  include Sidekiq::Worker

  def perform(request_params, upload_job)
    upload_job.crawling!
    if request_params[:action] == "url_crawl"
      url = request_params[:crawl_url]
      start_page = request_params[:start_page_num].to_i
      end_page = request_params[:end_page_num].to_i
      images = Datapool::WebSiteImageMetum.crawl_images!(url: url, start_page: start_page, end_page: end_page, filter: request_params[:filter])
    elsif request_params[:action] == "flickr_crawl"
      search_type = request_params[:search_type].to_i
      search_hash = {}
      if search_type == 1
        search_hash[:tags] = request_params[:keyword].to_s
      else
        search_hash[:text] = request_params[:keyword].to_s
      end
      images = Datapool::FrickrImageMetum.search_images!(search: search_hash)
    else
      if search_type == 1
        images = Datapool::TwitterImageMetum.images_from_user_timeline!(keyword: request_params[:keyword].to_s)
      else
        images = Datapool::TwitterImageMetum.search_image_tweet!(keyword: request_params[:keyword].to_s)
      end
    end
    if images.blank?
      upload_job.failed!
      return
    end
    Tempfile.create(SecureRandom.hex) do |tempfile|
      upload_job.compressing!
      zippath = compress_to_zip(zip_filepath: tempfile.path, images: images)
      upload_job.uploading!

      zipfile = File.open(zippath)
      zipfile_size = zipfile.size
      upload_file_path = Datapool::ImageMetum.upload_s3(zipfile, "#{Time.now.strftime("%Y%m%d_%H%M%S")}_#{request_params[:action]}.zip")
      upload_job.update!(state: :complete, upload_url: ApplicationRecord::S3_ROOT_URL + upload_file_path, upload_file_size: zipfile_size)
    end
  end

  private
  def compress_to_zip(zip_filepath:, images: [])
    filename_hash = {}
    Zip::OutputStream.open(zip_filepath) do |stream|
      images.each do |image|
        response = image.download_image_response
        next if (response.status >= 300 && response.status != 304) || !response.headers["Content-Type"].to_s.include?("image")
        if filename_hash[image.save_filename].nil?
          stream.put_next_entry(image.save_filename)
        else
          stream.put_next_entry(SecureRandom.hex + File.extname(image.save_filename))
        end
        stream.print(response.body)
        filename_hash[image.save_filename] = image
      end
    end
    return zip_filepath
  end
end
