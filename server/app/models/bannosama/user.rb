# == Schema Information
#
# Table name: bannosama_users
#
#  id                 :integer          not null, primary key
#  type               :string(255)
#  name               :string(255)
#  thumnail_image_url :string(255)
#  uuid               :string(255)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_agent         :text(65535)
#
# Indexes
#
#  index_bannosama_users_on_uuid  (uuid) UNIQUE
#

class Bannosama::User < ApplicationRecord
  before_create do
    self.uuid = SecureRandom.hex
  end

  has_many :send_greets, class_name: 'Bannosama::Greet', foreign_key: :from_user_id
  has_many :receive_greets, class_name: 'Bannosama::Greet', foreign_key: :to_user_id
end
