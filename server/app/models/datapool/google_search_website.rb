# == Schema Information
#
# Table name: datapool_websites
#
#  id         :bigint(8)        not null, primary key
#  type       :string(255)
#  title      :string(255)      not null
#  origin_src :string(255)      not null
#  other_src  :text(65535)
#  options    :text(65535)
#
# Indexes
#
#  index_datapool_websites_on_origin_src  (origin_src)
#  index_datapool_websites_on_title       (title)
#

class Datapool::GoogleSearchWebsite < Datapool::Website
end
