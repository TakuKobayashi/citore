class CreateDatapoolAudioAlbums < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_audio_albums do |t|
      t.string :type
      t.string :title, null: false, default: ""
      t.string :album_id, null: false
      t.string :image_url
      t.string :url
      t.text :track_ids
      t.text :options
    end
    add_index :datapool_audio_albums, [:album_id, :type], unique: true
  end
end
