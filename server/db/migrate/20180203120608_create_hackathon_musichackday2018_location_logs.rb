class CreateHackathonMusichackday2018LocationLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_musichackday2018_location_logs do |t|
      t.integer :user_id, null: false
      t.float :lat, null: false, default: 0
      t.float :lon, null: false, default: 0
      t.timestamps
    end
    add_index :hackathon_musichackday2018_location_logs, :user_id
    add_index :hackathon_musichackday2018_location_logs, [:lat, :lon], name: "musichackday2018_lat_lon_log_index"
  end
end
