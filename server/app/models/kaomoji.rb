# == Schema Information
#
# Table name: kaomojis
#
#  id       :integer          not null, primary key
#  category :string(255)      not null
#  meaning  :string(255)      not null
#  body     :string(255)      not null
#
# Indexes
#
#  index_kaomojis_on_category  (category)
#  index_kaomojis_on_meaning   (meaning)
#

class Kaomoji < ApplicationRecord
end
