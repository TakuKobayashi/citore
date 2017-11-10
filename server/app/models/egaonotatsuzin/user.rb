# == Schema Information
#
# Table name: egaonotatsuzin_users
#
#  id               :integer          not null, primary key
#  token            :string(255)      not null
#  last_accessed_at :datetime         not null
#  user_agent       :text(65535)
#  options          :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_egaonotatsuzin_users_on_last_accessed_at  (last_accessed_at)
#  index_egaonotatsuzin_users_on_token             (token) UNIQUE
#

class Egaonotatsuzin::User < ApplicationRecord
  serialize :options, JSON
  has_one :spotify, class_name: 'SpotifyAccount', as: :user

  def sign_in!
    self.last_accessed_at = Time.current
    self.save!
  end
end
