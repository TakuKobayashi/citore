# == Schema Information
#
# Table name: wikipedia_pages
#
#  id            :integer          not null, primary key
#  namespace     :integer          default(0), not null
#  title         :binary(255)      default(""), not null
#  restrictions  :binary(255)      default(""), not null
#  counter       :integer          default(0), not null
#  is_redirect   :boolean          default(FALSE), not null
#  is_new        :boolean          default(FALSE), not null
#  random        :float(53)        default(0.0), not null
#  touched       :binary(14)       default(""), not null
#  links_updated :binary(14)
#  latest        :integer          default(0), not null
#  len           :integer          default(0), not null
#  content_model :binary(32)
#  lang          :binary(35)
#
# Indexes
#
#  len                     (len)
#  name_title              (namespace,title) UNIQUE
#  random                  (random)
#  redirect_namespace_len  (is_redirect,namespace,len)
#

require 'test_helper'

class WikipediaPageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
