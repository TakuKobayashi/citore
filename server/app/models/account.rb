# == Schema Information
#
# Table name: accounts
#
#  id           :integer          not null, primary key
#  user_type    :string(255)      not null
#  user_id      :integer          not null
#  type         :string(255)
#  uid          :string(255)      not null
#  token        :text(65535)
#  token_secret :text(65535)
#  expired_at   :datetime
#  options      :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_accounts_on_uid                      (uid)
#  unique_user_and_id_and_uid_accounts_index  (user_type,user_id,type,uid) UNIQUE
#

class Account < ApplicationRecord
  serialize :options, JSON
  belongs_to :user, polymorphic: true, required: false

  def self.sign_up!(user: ,omni_auth:)
    account = self.find_or_initialize_by(user: user, uid: omni_auth.uid)
    account.token = omni_auth.credentials.token
    account.options = {extra: omni_auth.extra.to_hash}
    account.save!
  end

  def expired?
    self.expired_at.present? && self.expired_at >= Time.current
  end
end
