# == Schema Information
#
# Table name: datapool_video_meta
#
#  id                :integer          not null, primary key
#  type              :string(255)
#  title             :string(255)      not null
#  front_image_url   :text(65535)
#  data_category     :integer          default("file"), not null
#  bitrate           :integer          default(0), not null
#  original_filename :string(255)
#  origin_src        :string(255)      not null
#  other_src         :text(65535)
#  options           :text(65535)
#
# Indexes
#
#  index_datapool_video_meta_on_origin_src  (origin_src)
#  index_datapool_video_meta_on_title       (title)
#

class Datapool::WebSiteVideoMetum < Datapool::VideoMetum
end
