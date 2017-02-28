# == Schema Information
#
# Table name: job_with_life_configs
#
#  id                          :integer          not null, primary key
#  job_with_life_admin_user_id :integer          not null
#  hwid                        :string(255)      not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  record_job_config_admin_user_index  (job_with_life_admin_user_id)
#  record_job_config_hwid_index        (job_with_life_admin_user_id)
#

require 'test_helper'

class JobWithLife::ConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
