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
end
