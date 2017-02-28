class CreateSpotgachaInputLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :spotgacha_input_locations do |t|
      t.string :input_user_type, null: false
      t.integer :input_user_id, null: false
      t.float :latitude, null: false, default: 0
      t.float :longitude, null: false, default: 0
      t.string :address
      t.timestamps
    end
    add_index :spotgacha_input_locations, [:input_user_type, :input_user_id], name: "spotgacha_input_locations_user_index"
    add_index :spotgacha_input_locations, [:latitude, :longitude], name: "spotgacha_input_locations_latlon_index"
  end
end
