class CreateFoodForecastUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_users do |t|
      t.string :name
      t.string :token, null: false
      t.text :push_token
      t.datetime :last_login_at, null: false
      t.timestamps
    end
    add_index :food_forecast_users, :token, unique: true
    add_index :food_forecast_users, :last_login_at
  end
end
