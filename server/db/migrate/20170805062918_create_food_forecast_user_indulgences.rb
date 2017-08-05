class CreateFoodForecastUserIndulgences < ActiveRecord::Migration[5.1]
  def change
    create_table :food_forecast_user_indulgences do |t|
      t.integer :user_id, null: false
      t.integer :category, null: false, default: 0
      t.string :word, null: false
    end

    add_index :food_forecast_user_indulgences, :user_id, name: "user_indulgences_user_id_index"
    add_index :food_forecast_user_indulgences, :word, name: "user_indulgences_word_index"
  end
end
