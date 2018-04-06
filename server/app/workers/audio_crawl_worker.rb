class AudioCrawlWorker < CrawlWorkerBase
  def perform(request_params, upload_job_id)
    upload_job = Homepage::UploadJobQueue.find_by(id: upload_job_id)
    upload_job.executing!
    if request_params["crawl_type"] == "website"
      url = Sanitizer.basic_sanitize(request_params["crawl_url"].to_s)
      start_page = request_params["start_page_num"].to_i
      end_page = request_params["end_page_num"].to_i
      upload_job.options = upload_job.options.merge({url: url, start_page: start_page, end_page: end_page})
      audios = Datapool::WebSiteAudioMetum.suppress_to_children!(url: url, page_key: request_params["page_key"], start_page: start_page, end_page: end_page)
    end
    upload_job.save!
    resources_in_one_package_and_upload_s3!(upload_job: upload_job, resources: audios, split_size: 500)
  end
end
