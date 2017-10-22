class AudioCrawlWorker
  include Sidekiq::Worker

  def perform(request_params, upload_job_id)
    upload_job = Homepage::UploadJobQueue.find_by(id: upload_job_id)
    upload_job.crawling!
    if request_params["crawl_type"] == "website"
      url = ApplicationRecord.basic_sanitize(request_params["crawl_url"].to_s)
      start_page = request_params["start_page_num"].to_i
      end_page = request_params["end_page_num"].to_i
      upload_job.options = upload_job.options.merge({url: url, start_page: start_page, end_page: end_page})
      audios = Datapool::WebSiteAudioMetum.suppress_to_children!(url: url, page_key: request_params["page_key"], start_page: start_page, end_page: end_page)
    end
    upload_job.save!
    if audios.blank?
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
    audios.each_slice(100).with_index do |slice_audios, index|
      if index == 0
        job = upload_job
      else
        job = Homepage::UploadJobQueue.create(take_over_hash)
      end
      job.compress_and_upload_audios!(audios: slice_audios)
    end
  end
end
