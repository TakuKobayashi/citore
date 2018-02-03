class CreateHackathonMusichackday2018LastLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_musichackday2018_last_locations do |t|
      t.integer :user_id, null: false
      t.integer :log_id, null: false
      t.float :lat, null: false, default: 0
      t.float :lon, null: false, default: 0
      t.datetime :received_at, null: false
    end
    add_index :hackathon_musichackday2018_last_locations, :user_id
    add_index :hackathon_musichackday2018_last_locations, [:lat, :lon], name: "musichackday2018_lat_lon_last_location_index"
    add_index :hackathon_musichackday2018_last_locations, :received_at
  end
end
