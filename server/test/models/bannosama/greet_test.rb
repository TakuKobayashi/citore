# == Schema Information
#
# Table name: bannosama_greets
#
#  id               :integer          not null, primary key
#  from_user_id     :integer
#  to_user_id       :integer
#  state            :integer          default("uploaded"), not null
#  message          :text(65535)
#  theme            :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  audio_upload_url :string(255)
#
# Indexes
#
#  index_bannosama_greets_on_from_user_id  (from_user_id)
#  index_bannosama_greets_on_to_user_id    (to_user_id)
#

require 'test_helper'

class Bannosama::GreetTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
