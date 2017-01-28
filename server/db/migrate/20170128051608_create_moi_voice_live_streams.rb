class CreateMoiVoiceLiveStreams < ActiveRecord::Migration[5.0]
  def change
    create_table :moi_voice_live_streams do |t|
      t.integer :moi_voice_twitcas_user_id, null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :state, null: false
      t.timestamps
    end
    add_index :moi_voice_live_streams, [:moi_voice_twitcas_user_id, :state], name: "moi_voice_live_streams_user_id_index"
    add_index :moi_voice_live_streams, [:started_at, :finished_at], name: "moi_voice_live_finished_at_index"
  end
end
