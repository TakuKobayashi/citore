class AddColumnVideoIdToLiveStream < ActiveRecord::Migration[5.0]
  def change
    add_column :moi_voice_live_streams, :video_id, :string
  end
end
