# == Schema Information
#
# Table name: hackathon_musichackday2018_remix_sounds
#
#  id             :integer          not null, primary key
#  user_id        :integer          not null
#  state          :integer          default("standby"), not null
#  to_user_id     :integer          not null
#  base_sound_id  :integer          not null
#  over_sound_id  :integer          not null
#  remix_file_url :string(255)
#  options        :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_hackathon_musichackday2018_remix_sounds_on_to_user_id  (to_user_id)
#  index_hackathon_musichackday2018_remix_sounds_on_user_id     (user_id)
#

class Hackathon::Musichackday2018::RemixSound < ApplicationRecord
  enum state: {
    standby: 0,
    stocked: 1,
    released: 2,
    removed: 3
  }
end
