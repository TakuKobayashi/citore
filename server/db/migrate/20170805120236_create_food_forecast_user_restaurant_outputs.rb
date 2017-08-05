class CreateFoodForecastUserRestaurantOutputs < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_user_restaurant_outputs do |t|
      t.integer :user_id, null: false
      t.integer :user_location_id
      t.string :information_type, null: false
      t.float :latitude, null: false, default: 0
      t.float :longitude, null: false, default: 0
      t.string :address
      t.string :phone_number
      t.string :place_id, null: false
      t.string :place_name, null: false
      t.string :place_name_reading, null: false
      t.text :place_description, null: false
      t.string :url, null: false
      t.string :image_url
      t.string :coupon_url
      t.datetime :recommended_at, null: false
      t.boolean :is_select, null: false, default: false
      t.string :opentime, null: false, default: ""
      t.string :holiday, null: false, default: ""
      t.integer :page_number, null: false, null: false
      t.text :options
      t.timestamps
    end
    add_index :food_forecast_user_restaurant_outputs, :user_id, name: "restaurant_outputs_user_id_index"
    add_index :food_forecast_user_restaurant_outputs, :user_location_id, name: "restaurant_outputs_location_id_index"
    add_index :food_forecast_user_restaurant_outputs, [:latitude, :longitude], name: "restaurant_outputs_lat_lon_index"
    add_index :food_forecast_user_restaurant_outputs, :place_id, name: "restaurant_outputs_place_id_index"
    add_index :food_forecast_user_restaurant_outputs, :recommended_at, name: "restaurant_outputs_recommended_at_index"
  end
end
