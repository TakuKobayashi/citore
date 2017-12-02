# == Schema Information
#
# Table name: hackathon_sunflower_worker_resources
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  worker_id     :integer          not null
#  resource_id   :integer          not null
#  adjust_width  :integer          default(0), not null
#  adjust_height :integer          default(0), not null
#  column_index  :integer          default(0), not null
#  row_index     :integer          default(0), not null
#
# Indexes
#
#  composite_worker_resources_user_id_index          (user_id)
#  composite_worker_resources_worker_resource_index  (worker_id,resource_id)
#

class Hackathon::Sunflower::WorkerResource < ApplicationRecord
end
