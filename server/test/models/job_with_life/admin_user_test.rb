# == Schema Information
#
# Table name: job_with_life_admin_users
#
#  id               :integer          not null, primary key
#  daily_reset_hour :integer          default(0), not null
#  name             :string(255)      not null
#  password         :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  record_job_admin_user_login_index  (name,password)
#

require 'test_helper'

class JobWithLife::AdminUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
