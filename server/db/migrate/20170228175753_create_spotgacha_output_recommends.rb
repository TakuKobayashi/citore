class CreateSpotgachaOutputRecommends < ActiveRecord::Migration[5.0]
  def change
    create_table :spotgacha_output_recommends do |t|
      t.integer :input_location_id, null: false
      t.string :output_user_type, null: false
      t.integer :output_user_id, null: false
      t.string :information_type, null: false
      t.float :latitude, null: false, default: 0
      t.float :longitude, null: false, default: 0
      t.string :address
      t.string :phone_number
      t.string :place_name, null: false
      t.string :place_id, null: false
      t.datetime :recommended_at, null: false
      t.boolean :is_select, null: false, default: false
      t.timestamps
    end
    add_index :spotgacha_output_recommends, :input_location_id
    add_index :spotgacha_output_recommends, [:output_user_type, :output_user_id], name: "spotgacha_output_recommends_user_index"
    add_index :spotgacha_output_recommends, [:latitude, :longitude], name: "spotgacha_output_recommends_latlon_index"
    add_index :spotgacha_output_recommends, :place_id
    add_index :spotgacha_output_recommends, :recommended_at
  end
end
