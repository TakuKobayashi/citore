class AudiorawlWorker
  include Sidekiq::Worker

  def perform(request_params, upload_job_id)
    upload_job = Homepage::UploadJobQueue.find_by(id: upload_job_id)
    upload_job.crawling!
    if request_params["action"] == "url_crawl"
      url = ApplicationRecord.basic_sanitize(request_params["crawl_url"].to_s)
      upload_job.options = upload_job.options.merge({url: url})
      audios = Datapool::WebSiteAudioMetum.suppress!(url: url)
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
    audios.each_slice(10).with_index do |slice_audios, index|
      if index == 0
        job = upload_job
      else
        job = Homepage::UploadJobQueue.create(take_over_hash)
      end
    end
  end
end
