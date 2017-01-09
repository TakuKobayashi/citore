# == Schema Information
#
# Table name: linebot_events
#
#  id                      :integer          not null, primary key
#  type                    :string(255)      not null
#  message_type            :string(255)      not null
#  linebot_followe_user_id :integer          not null
#  line_user_id            :string(255)      not null
#  input_file_path         :string(255)
#  output_file_path        :string(255)
#  input_text              :text(65535)
#  output_text             :text(65535)
#  address                 :string(255)
#  latitude                :float(24)
#  longitude               :float(24)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_linebot_events_on_line_user_id  (line_user_id)
#  linebot_event_indexes                 (linebot_followe_user_id,type,message_type)
#

class Citore::LinebotEvent < LinebotEvent
end
