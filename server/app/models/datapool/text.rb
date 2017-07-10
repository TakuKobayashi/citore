# == Schema Information
#
# Table name: datapool_texts
#
#  id       :integer          not null, primary key
#  type     :string(255)
#  body     :text(65535)      not null
#  from_url :string(255)
#
# Indexes
#
#  index_datapool_texts_on_from_url  (from_url)
#

class Datapool::Text < ApplicationRecord
end
