# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

health_csv = CSV.read(Rails.root.to_s + "/health.csv")
food_csv = CSV.read(Rails.root.to_s + "/food.csv")
health_food_csv = CSV.read(Rails.root.to_s + "/health_food.csv")


FoodForecast::MstHealth.connection.execute("TRUNCATE TABLE #{FoodForecast::MstHealth.table_name}")
healthes = health_csv.map do |title_arr|
  FoodForecast::MstHealth.new(name: title_arr.first)
end
FoodForecast::MstHealth.import(healthes)

word_food = FoodForecast::MstFood::CLASSIFICATION_WORDS.invert
FoodForecast::MstFood.connection.execute("TRUNCATE TABLE #{FoodForecast::MstFood.table_name}")
FoodForecast::MstFoodComponent.connection.execute("TRUNCATE TABLE #{FoodForecast::MstFoodComponent.table_name}")
food_csv.each_with_index do |foods, row_index|
  if row_index < 2
    next
  end
  food = FoodForecast::MstFood.create!(
      food_id: foods[1],
      name: foods[3],
      classification: word_food[foods[2]],
      disposal: foods[6].to_f,
      kcal: foods[7].to_f,
      corrected_kcal: foods[8].to_f
  )
  compoments = foods[9..foods.size]
  food_components = []
  compoments.each_with_index do |compoment, index|
    next if compoment.blank?
    food_components << food.components.new(factor: index, value: compoment.to_f)
  end
  FoodForecast::MstFoodComponent.import(food_components)
end

#AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')