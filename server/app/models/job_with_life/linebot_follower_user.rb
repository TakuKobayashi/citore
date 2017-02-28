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

class JobWithLife::LinebotFollowerUser < LinebotFollowerUser
  has_many :job_with_life_beacon_access_logs, as: :answer_user

  def record_and_answer!(event:)
    last_access = self.job_with_life_beacon_access_logs.where(hwid: event["beacon"]["hwid"],beacon_type: event["beacon"]["type"]).last
    #TODO 登録した時間を基準にする(0時とは限らない)
    if last_access.present? && last_access.record_time.today?
      daily_number = last_access.daily_record_number + 1
    else
      daily_number = 1
    end
    log = self.job_with_life_beacon_access_logs.create!(
      timestamp: event["timestamp"],
      beacon_type: event["beacon"]["type"],
      hwid: event["beacon"]["hwid"],
      record_time: Time.current,
      daily_record_number: daily_number,
  	)
    if daily_number == 1 && log.beacon_type == "enter"
      return "おはようございます。\n" + log.record_time.strftime("%Y年%m月%d日 %H時%M分%S秒") + "\n出社、記録しました。\n本日も一日頑張っていきましょう!!"
    else
      if log.beacon_type == "enter"
        return "お帰りなさい\n" + "本日、#{daily_number}回目の出社ですね♪"
      else
        return "お疲れ様です\n" + "本日、#{daily_number}回目の退社ですね♪"
      end
    end
  end
end