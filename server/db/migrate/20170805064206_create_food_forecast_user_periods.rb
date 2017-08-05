class CreateFoodForecastUserPeriods < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_user_periods do |t|
      t.integer :user_id, null: false
      t.datetime :first_at, null: false
      t.datetime :second_at, null: false
      t.datetime :third_at, null: false
      t.float :first_span_day, null: false, default: 0
      t.float :second_span_day, null: false, default: 0
      t.timestamps
    end
    add_index :food_forecast_user_periods, :user_id, name: "user_periods_user_id_index"
    add_index :food_forecast_user_periods, :first_at, name: "user_periods_first_at_index"
    add_index :food_forecast_user_periods, :second_at, name: "user_periods_second_at_index"
    add_index :food_forecast_user_periods, :first_span_day, name: "user_periods_first_span_index"
  end
end
