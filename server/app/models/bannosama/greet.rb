# == Schema Information
#
# Table name: bannosama_greets
#
#  id           :integer          not null, primary key
#  from_user_id :integer
#  to_user_id   :integer
#  state        :integer          default("uploaded"), not null
#  title        :string(255)      not null
#  message      :text(65535)
#  theme        :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_bannosama_greets_on_from_user_id  (from_user_id)
#  index_bannosama_greets_on_to_user_id    (to_user_id)
#

class Bannosama::Greet < ApplicationRecord
  has_many :images, class_name: 'Bannosama::GreetImage', foreign_key: :greet_id
  belongs_to :to_user, class_name: 'Bannosama::User', foreign_key: :to_user_id, required: false
  belongs_to :from_user, class_name: 'Bannosama::User', foreign_key: :from_user_id, required: false

  enum state: [:uploaded, :received, :checked, :responsed]
end
