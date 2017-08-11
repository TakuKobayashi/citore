# == Schema Information
#
# Table name: homepage_articles
#
#  id            :integer          not null, primary key
#  type          :string(255)
#  title         :string(255)      not null
#  description   :text(65535)
#  url           :string(255)      not null
#  thumbnail_url :string(255)
#  pubulish_at   :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_homepage_articles_on_pubulish_at  (pubulish_at)
#

require 'test_helper'

class Homepage::ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
