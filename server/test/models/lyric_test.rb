# == Schema Information
#
# Table name: lyrics
#
#  id          :integer          not null, primary key
#  title       :string(255)      not null
#  artist_name :string(255)      not null
#  word_by     :string(255)
#  music_by    :string(255)
#  body        :text(65535)      not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_lyrics_on_artist_name  (artist_name)
#  index_lyrics_on_title        (title)
#

require 'test_helper'

class LyricTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
