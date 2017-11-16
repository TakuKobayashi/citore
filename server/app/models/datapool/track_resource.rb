# == Schema Information
#
# Table name: datapool_track_resources
#
#  id            :integer          not null, primary key
#  resource_type :string(255)      not null
#  resource_id   :integer          not null
#  track_id      :integer          not null
#
# Indexes
#
#  datapool_track_resources_unique_relation_index  (resource_type,resource_id,track_id) UNIQUE
#  index_datapool_track_resources_on_track_id      (track_id)
#

class Datapool::TrackResource < ApplicationRecord
end
