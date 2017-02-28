# == Schema Information
#
# Table name: job_with_life_beacon_access_logs
#
#  id                  :integer          not null, primary key
#  answer_user_type    :string(255)      not null
#  answer_user_id      :integer          not null
#  record_time         :datetime         not null
#  daily_record_number :integer          default(0), not null
#  hwid                :string(255)      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  record_job_hwid_index  (hwid)
#  record_job_time_index  (record_time)
#  record_job_user_index  (answer_user_type,answer_user_id)
#

class JobWithLife::BeaconAccessLog < ApplicationRecord
end
