# == Schema Information
#
# Table name: datapool_hatsugen_komachis
#
#  id                :integer          not null, primary key
#  topic_id          :integer          not null
#  res_number        :string(255)      not null
#  top_res_flag      :string(255)      not null
#  title             :string(255)      not null
#  body              :text(65535)
#  handle_name       :string(255)      not null
#  posted_at         :datetime         not null
#  publish_flag      :string(255)      not null
#  parent_topic_flag :string(255)      not null
#  komachi_user_id   :integer          not null
#  advice            :text(65535)
#  funny             :integer          default(0), not null
#  surprise          :integer          default(0), not null
#  tears             :integer          default(0), not null
#  yell              :integer          default(0), not null
#  isee              :integer          default(0), not null
#  genre_code        :string(255)      default(""), not null
#  res_state         :string(255)
#  facemark_id       :string(255)
#  remark            :text(65535)
#  post_device       :string(255)
#
# Indexes
#
#  index_datapool_hatsugen_komachis_on_genre_code               (genre_code)
#  index_datapool_hatsugen_komachis_on_komachi_user_id          (komachi_user_id)
#  index_datapool_hatsugen_komachis_on_posted_at                (posted_at)
#  index_datapool_hatsugen_komachis_on_topic_id_and_res_number  (topic_id,res_number)
#

require 'test_helper'

class Datapool::HatsugenKomachiTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
