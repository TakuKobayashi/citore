class ImageCrawlWorker
  include Sidekiq::Worker

  def perform(request_params, upload_job_id)
    upload_job = Homepage::UploadJobQueue.find_by(id: upload_job_id)
    upload_job.crawling!
    if request_params["action"] == "url_crawl"
      url = request_params["crawl_url"]
      start_page = request_params["start_page_num"].to_i
      end_page = request_params["end_page_num"].to_i
      upload_job.options = upload_job.options.merge({url: url, start_page: start_page, end_page: end_page})
      images = Datapool::WebSiteImageMetum.crawl_images!(url: url, page_key: request_params["page_key"], start_page: start_page, end_page: end_page, filter: request_params["filter"])
    elsif request_params["action"] == "flickr_crawl"
      search_type = request_params["search_type"].to_i
      search_hash = {}
      if search_type == 1
        search_hash[:tags] = request_params["keyword"].to_s
      else
        search_hash[:text] = request_params["keyword"].to_s
      end
      upload_job.options = upload_job.options.merge({keyword: request_params["keyword"].to_s, search_type: search_type})
      images = Datapool::FrickrImageMetum.search_images!(search: search_hash)
    elsif request_params["action"] == "twitter_crawl"
      search_type = request_params["search_type"].to_i
      upload_job.options = upload_job.options.merge({keyword: request_params["keyword"].to_s, search_type: search_type})
      if search_type == 1
        images = Datapool::TwitterImageMetum.images_from_user_timeline!(username: request_params["keyword"].to_s)
      else
        images = Datapool::TwitterImageMetum.search_image_tweet!(keyword: request_params["keyword"].to_s)
      end
    else
      upload_job.options = upload_job.options.merge({keyword: request_params["keyword"].to_s})
      images = Datapool::GoogleImageSearch.crawl_images!(keyword: request_params["keyword"])
    end
    upload_job.save!
    if images.blank?
      upload_job.failed!
      return
    end
    take_over_hash = {
      homepage_access_id: upload_job.homepage_access_id,
      token: upload_job.token,
      from_type: upload_job.from_type,
      state: upload_job.state,
      options: upload_job.options
    }
    # 画像の数が多いとメモリに乗り切らないおそれがあるので500件ずつに区切って処理を行おうと思う
    images.each_slice(500).with_index do |slice_images, index|
      if index == 0
        job = upload_job
      else
        job = Homepage::UploadJobQueue.create(take_over_hash)
      end
      job.compress_and_upload_images!(images: slice_images)
    end
  end
end
