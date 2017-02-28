# == Schema Information
#
# Table name: linebot_follower_users
#
#  id             :integer          not null, primary key
#  type           :string(255)      not null
#  line_user_id   :string(255)      not null
#  display_name   :string(255)      not null
#  picture_url    :string(255)
#  status_message :text(65535)
#  unfollow       :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_linebot_follower_users_on_line_user_id_and_type  (line_user_id,type) UNIQUE
#

class LinebotFollowerUser < ApplicationRecord
  def self.generate_profile!(line_client: , line_user_id:, isfollow: true)
    follower = self.find_or_initialize_by(type: self.class.name, line_user_id: line_user_id)
    if follower.new_record?
      response = line_client.get_profile(line_user_id)
      profile = response.body
      follower.display_name = profile["displayName"]
      follower.picture_url = profile["pictureUrl"]
      follower.status_message = profile["statusMessage"]
    end
    if isfollow
      follower.follow!
    else
      follower.unfollow!
    end
    return follower
  end

  def follow!
    update!(unfollow: false)
  end

  def unfollow!
    update!(unfollow: false)
  end
end
