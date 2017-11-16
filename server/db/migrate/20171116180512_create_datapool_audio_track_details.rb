class CreateDatapoolAudioTrackDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_audio_track_details do |t|
      t.integer :track_id, null: false
      t.integer :sample_rate, null: false, default: 0
      t.float :tempo, null: false, default: 0
      t.float :start_of_fade_out, null: false, default: 0
      t.float :end_of_fade_in, null: false, default: 0
      t.float :loudness, null: false, default: 0
      t.integer :key, null: false, default: 0
      t.integer :mode, null: false, default: 0
      t.text :options
    end
    add_index :datapool_audio_track_details, :track_id
  end
end
