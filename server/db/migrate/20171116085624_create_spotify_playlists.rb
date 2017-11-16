class CreateSpotifyPlaylists < ActiveRecord::Migration[5.1]
  def change
    create_table :spotify_playlists do |t|
      t.integer :account_id, null: false
      t.string :playlist_id, null: false
      t.string :name
      t.string :image_url
      t.string :url
      t.boolean :pulishing, null: false, default: false
      t.text :options
      t.timestamps
    end
    add_index :spotify_playlists, :account_id
    add_index :spotify_playlists, :playlist_id
  end
end
