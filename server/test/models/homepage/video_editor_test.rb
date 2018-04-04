# == Schema Information
#
# Table name: homepage_video_editors
#
#  id                 :integer          not null, primary key
#  homepage_access_id :integer          not null
#  state              :integer          default(0), not null
#  upload_video_url   :string(255)
#  edited_video_url   :string(255)
#  execute_command    :text(65535)
#  options            :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_homepage_video_editors_on_homepage_access_id  (homepage_access_id)
#

require 'test_helper'

class Homepage::VideoEditorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
