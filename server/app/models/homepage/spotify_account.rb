# == Schema Information
#
# Table name: homepage_accounts
#
#  id                 :integer          not null, primary key
#  homepage_access_id :integer          not null
#  type               :string(255)
#  uid                :string(255)      not null
#  token              :string(255)
#  token_secret       :string(255)
#  expired_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_homepage_accounts_on_homepage_access_id  (homepage_access_id)
#  index_homepage_accounts_on_uid                 (uid)
#

class Homepage::SpotifyAccount < Homepage::Account
end