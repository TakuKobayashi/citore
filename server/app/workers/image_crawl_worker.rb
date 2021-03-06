class ImageCrawlWorker < CrawlWorkerBase
  def perform(request_params, upload_job_id)
    upload_job = Homepage::UploadJobQueue.find_by(id: upload_job_id)
    upload_job.executing!
    if request_params["action"] == "url_crawl"
      url = Sanitizer.basic_sanitize(request_params["crawl_url"].to_s)
      start_page = request_params["start_page_num"].to_i
      end_page = request_params["end_page_num"].to_i
      upload_job.options = upload_job.options.merge({url: url, start_page: start_page, end_page: end_page})
      images = Datapool::WebSiteImageMetum.crawl_images!(url: url, page_key: request_params["page_key"], start_page: start_page, end_page: end_page, filter: request_params["filter"])
    elsif request_params["action"] == "flickr_crawl"
      search_type = request_params["search_type"].to_i
      search_hash = {}
      keyword = Sanitizer.basic_sanitize(request_params["keyword"].to_s)
      if search_type == 1
        search_hash[:tags] = keyword
      else
        search_hash[:text] = keyword
      end
      upload_job.options = upload_job.options.merge({keyword: keyword, search_type: search_type})
      images = Datapool::FrickrImageMetum.search_images!(search: search_hash)
    elsif request_params["action"] == "twitter_crawl"
      keyword = Sanitizer.basic_sanitize(request_params["keyword"].to_s)
      search_type = request_params["search_type"].to_i
      upload_job.options = upload_job.options.merge({keyword: keyword, search_type: search_type})
      if search_type == 1
        images = Datapool::TwitterImageMetum.images_from_user_timeline!(username: keyword)
      else
        images = Datapool::TwitterImageMetum.search_image_tweet!(keyword: keyword)
      end
    elsif request_params["action"] ==  "niconico_crawl"
      keyword = Sanitizer.basic_sanitize(request_params["keyword"].to_s)
      upload_job.options = upload_job.options.merge({keyword: keyword})
      images = Datapool::NiconicoImageMetum.crawl_images!(keyword: keyword)
    elsif request_params["action"] ==  "getty_images_crawl"
      keyword = Sanitizer.basic_sanitize(request_params["keyword"].to_s)
      upload_job.options = upload_job.options.merge({keyword: keyword})
      images = Datapool::GettyImageMetum.crawl_images!(keyword: keyword)
    else
      keyword = Sanitizer.basic_sanitize(request_params["keyword"].to_s)
      upload_job.options = upload_job.options.merge({keyword: keyword})
      images = Datapool::GoogleImageSearch.crawl_images!(keyword: keyword)
    end
    upload_job.save!
    resources_in_one_package_and_upload_s3!(upload_job: upload_job, resources: images, split_size: 500)
  end
end
