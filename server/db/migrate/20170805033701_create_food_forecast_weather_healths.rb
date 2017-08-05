class CreateFoodForecastWeatherHealths < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_weather_healths do |t|
      t.integer :mst_weather_id, null: false
      t.integer :mst_health_id, null: false
    end

    add_index :food_forecast_weather_healths, [:mst_weather_id, :mst_health_id], name: "weather_health_relation_index"
  end
end
