# == Schema Information
#
# Table name: hackathon_sunflower_users
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  token              :string(255)      not null
#  phone_number       :string(255)
#  email              :string(255)
#  reservation_number :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_hackathon_sunflower_users_on_email         (email)
#  index_hackathon_sunflower_users_on_phone_number  (phone_number)
#  index_hackathon_sunflower_users_on_token         (token)
#

class Hackathon::Sunflower::User < ApplicationRecord
  has_many :workers, class_name: 'Hackathon::Sunflower::CompositeWorker', foreign_key: :user_id
  has_many :resources, class_name: 'Hackathon::Sunflower::ImageResource', foreign_key: :user_id
  has_many :worker_resources, class_name: 'Hackathon::Sunflower::WorkerResource', foreign_key: :user_id
end
