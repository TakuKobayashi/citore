class CreateFoodForecastUserWeatherLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_user_weather_locations do |t|
      t.integer :user_id, null: false
      t.float :lat
      t.float :lon
      t.string :ip_address, null: false
      t.string :address
      t.datetime :accessed_at, null: false
      t.text :weather_reports
      t.timestamps
    end
    add_index :food_forecast_user_weather_locations, [:lat, :lon], name: "user_weather_locations_lat_lon_index"
    add_index :food_forecast_user_weather_locations, :ip_address, name: "user_weather_locations_ip_address_index"
    add_index :food_forecast_user_weather_locations, :user_id, name: "user_weather_locations_user_id_index"
    add_index :food_forecast_user_weather_locations, :accessed_at, name: "user_weather_locations_accessed_at_index"
  end
end
