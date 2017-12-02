# == Schema Information
#
# Table name: hackathon_sunflower_composite_workers
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  export_url :string(255)
#  category   :integer          not null
#  state      :integer          not null
#  options    :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  composite_worker_state_category_index  (state,category)
#  composite_worker_user_id_index         (user_id)
#

class Hackathon::Sunflower::CompositeWorker < ApplicationRecord
  serialize :options, JSON
  belongs_to :user, class_name: 'Hackathon::Sunflower::User', foreign_key: :user_id, required: false
  has_many :worker_resources, class_name: 'Hackathon::Sunflower::WorkerResource', foreign_key: :worker_id
  has_many :resources, through: :worker_resources, source: :resource

  enum cateogory: {
    ferry: 0,
    backgraound: 1,
    mixter: 2
  }

  enum state: {
    ready: 0,
    composite: 1,
    complete: 2,
  }
end
