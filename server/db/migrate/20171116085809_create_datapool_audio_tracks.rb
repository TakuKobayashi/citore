class CreateDatapoolAudioTracks < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_audio_tracks do |t|
      t.string :type
      t.integer :audio_metum_id
      t.string :title, null: false
      t.string :track_id, null: false
      t.string :isrc
      t.float :duration, null: false, default: 0
      t.string :url
      t.text :album_ids
      t.text :options
    end
    add_index :datapool_audio_tracks, [:track_id, :type], unique: true
    add_index :datapool_audio_tracks, :isrc
    add_index :datapool_audio_tracks, :audio_metum_id
  end
end
