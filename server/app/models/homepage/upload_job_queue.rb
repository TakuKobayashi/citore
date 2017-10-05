# == Schema Information
#
# Table name: homepage_upload_job_queues
#
#  id                 :integer          not null, primary key
#  homepage_access_id :integer          not null
#  from_type          :string(255)      not null
#  token              :string(255)      not null
#  state              :integer          default("standby"), not null
#  upload_url         :string(255)
#  upload_file_size   :integer
#  options            :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  homepage_job_queue_created_at_index  (created_at)
#  homepage_job_queue_token_index       (token)
#  homepage_job_queue_user_index        (homepage_access_id,state)
#

class Homepage::UploadJobQueue < ApplicationRecord
  serialize :options, JSON

  enum state: [:standby, :crawling, :compressing, :uploading, :complete, :downloaded, :failed]

  belongs_to :visitor, class_name: 'Homepage::Access', foreign_key: :homepage_access_id, required: false

  def self.cleanup!
    Homepage::UploadJobQueue.find_each do |job|
      next if job.standby?
      next if job.complete? && job.created_at > 7.day.ago
      next if (job.crawling? || job.compressing? || job.uploading?) && job.created_at > 8.hours.ago
      if job.upload_url.present?
        s3 = Aws::S3::Client.new
        filepath = job.upload_url.gsub(ApplicationRecord::S3_ROOT_URL, "")
        s3.delete_object(bucket: "taptappun", key: filepath)
      end
      job.destroy
    end
  end
end
