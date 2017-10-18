# == Schema Information
#
# Table name: homepage_accounts
#
#  id                 :integer          not null, primary key
#  homepage_access_id :integer          not null
#  type               :string(255)
#  uid                :string(255)      not null
#  token              :text(65535)
#  token_secret       :text(65535)
#  expired_at         :datetime
#  options            :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_homepage_accounts_on_uid  (uid)
#  unique_homepage_accounts_index  (homepage_access_id,type) UNIQUE
#

class Homepage::Account < ApplicationRecord
  serialize :options, JSON
  belongs_to :visitor, class_name: 'Homepage::Access', foreign_key: :homepage_access_id, required: false

  def self.sign_up!(visitor_id: ,omni_auth:)
    if omni_auth.provider == "spotify"
      account = Homepage::SpotifyAccount.find_or_initialize_by(homepage_access_id: visitor_id, uid: omni_auth.uid)
      account.token = omni_auth.credentials.token
      account.expired_at = Time.at(omni_auth.credentials.expires_at)
      account.options = {extra: omni_auth.extra.to_hash}
      account.save!
    end
  end
end
