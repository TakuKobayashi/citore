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

  enum state: {
    standby: 0,
    crawling: 1,
    compressing: 2,
    uploading: 3,
    complete: 4,
    downloaded: 5,
    failed: 6,
    cleaned: 7,
  }

  belongs_to :visitor, class_name: 'Homepage::Access', foreign_key: :homepage_access_id, required: false

  def self.cleanup!
    Homepage::UploadJobQueue.find_each do |job|
      next if job.standby?
      next if job.complete? && job.updated_at > 7.day.ago
      next if (job.crawling? || job.compressing? || job.uploading?) && job.updated_at > 8.hours.ago
      job.cleaned!
      if job.cleaned? && job.upload_url.present?
        s3 = Aws::S3::Client.new
        filepath = job.upload_url.gsub(ApplicationRecord::S3_ROOT_URL, "")
        s3.delete_object(bucket: "taptappun", key: filepath)
        job.update!(upload_url: nil, upload_file_size: nil)
      end
      if job.from_type == "Datapool::TwitterImageMetum"
        if job.options.present? && job.options["params"].present? && job.options["params"]["search_type"].to_i == 0
          Datapool::TwitterImageMetum.search_image_tweet!(keyword: job.options["params"]["keyword"].to_s)
        end
      end
    end
  end

  def compress_and_upload_images!(images:)
    Tempfile.create(SecureRandom.hex) do |tempfile|
      self.compressing!
      zippath = Datapool::ImageMetum.compress_to_zip(zip_filepath: tempfile.path, images: images)
      self.uploading!

      zipfile = File.open(zippath)
      zipfile_size = zipfile.size
      upload_file_path = Datapool::ImageMetum.upload_s3(zipfile, "#{Time.current.strftime("%Y%m%d_%H%M%S%L")}.zip")
      self.update!(state: :complete, upload_url: ApplicationRecord::S3_ROOT_URL + upload_file_path, upload_file_size: zipfile_size)
    end
  end

  def from_type_name
    if self.from_type == "Datapool::FrickrImageMetum"
      return I18n.t("activerecord.models.datapool_image_metum.flickr")
    elsif self.from_type == "Datapool::TwitterImageMetum"
      return I18n.t("activerecord.models.datapool_image_metum.twitter")
    elsif self.from_type == "Datapool::WebSiteImageMetum"
      return I18n.t("activerecord.models.datapool_image_metum.website")
    else
      return I18n.t("activerecord.models.datapool_image_metum.others")
    end
  end
end
