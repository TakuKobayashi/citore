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

class Homepage::SpotifyAccount < Homepage::Account
end
