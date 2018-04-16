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

class GoogleAccount < Account
  def upload_to_drive(upload_file)
    pathes = upload_file.path.split("/")
    service = Google::Apis::DriveV3::DriveService.new
    service.authorization = GoogleOauth2Client.oauth2_client(refresh_token: self.token, access_token: self.access_token)
    drive_file = Drive::File.new(title: pathes.last.to_s)
    uploaded_file = service.create_file(drive_file, upload_source: upload_file)
    return uploaded_file
  end

  def access_token
    if self.expired?
      return nil
    else
      return self.token_secret
    end
  end
end
