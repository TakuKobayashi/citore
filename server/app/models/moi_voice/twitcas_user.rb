# == Schema Information
#
# Table name: moi_voice_twitcas_users
#
#  id              :integer          not null, primary key
#  client_id       :string(255)      not null
#  name            :string(255)
#  access_token    :text(65535)
#  expires_in      :integer          default(0), not null
#  last_logined_at :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_moi_voice_twitcas_users_on_client_id  (client_id) UNIQUE
#

class MoiVoice::TwitcasUser < ApplicationRecord
end
