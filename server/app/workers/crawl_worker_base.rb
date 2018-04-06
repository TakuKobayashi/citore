class CrawlWorkerBase < SidekiqWorkerBase
  def resources_in_one_package_and_upload_s3!(upload_job:, resources:, split_size: 500)
    if resources.blank?
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
    # 数が多いとメモリに乗り切らないおそれがあるので何件かづつに区切って処理を行う
    resources.each_slice(split_size).with_index do |slice_resources, index|
      if index == 0
        job = upload_job
      else
        job = Homepage::UploadJobQueue.create(take_over_hash)
      end
      job.compress_resources_and_upload!(resources: slice_resources)
    end
  end
end