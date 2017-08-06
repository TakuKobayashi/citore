# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

health_csv = CSV.read(Rails.root.to_s + "/health.csv")
food_csv = CSV.read(Rails.root.to_s + "/food.csv")

weather_arr = []
FoodForecast::MstWeather.connection.execute("TRUNCATE TABLE #{FoodForecast::MstWeather.table_name}")
weather_arr << FoodForecast::MstWeather.new(name: "台風接近", factor: :typhoon, inequality: :lower_than, threshold: 1000000) #thresholdはm
weather_arr << FoodForecast::MstWeather.new(name: "湿度低", factor: :humidity, inequality: :lower_than, threshold: 30)
weather_arr << FoodForecast::MstWeather.new(name: "湿度高", factor: :humidity, inequality: :greater_equal, threshold: 70)
weather_arr << FoodForecast::MstWeather.new(name: "気温が低い", factor: :temperature, inequality: :lower_than, threshold: 20)
weather_arr << FoodForecast::MstWeather.new(name: "気温が高い", factor: :temperature, inequality: :greater_equal, threshold: 28)
weather_arr << FoodForecast::MstWeather.new(name: "梅雨", factor: :rainy_season, inequality: :equal, threshold: 6)
weather_arr << FoodForecast::MstWeather.new(name: "紫外線が強い", factor: :ultraviolet_rays, inequality: :greater_equal, threshold: 6) #http://www.data.jma.go.jp/gmd/env/uvhp/3-50uvindex_manual.html
weather_arr << FoodForecast::MstWeather.new(name: "PM2.5", factor: :pm_2_5, inequality: :greater_equal, threshold: 35)
weather_arr << FoodForecast::MstWeather.new(name: "寒暖の差が激しい", factor: :difference_temperature, inequality: :greater_equal, threshold: 5)
weather_arr << FoodForecast::MstWeather.new(name: "強風", factor: :strong_wind, inequality: :greater_equal, threshold: 12)
FoodForecast::MstWeather.import(weather_arr)


FoodForecast::MstHealth.connection.execute("TRUNCATE TABLE #{FoodForecast::MstHealth.table_name}")
healthes = health_csv.map do |title_arr|
  FoodForecast::MstHealth.new(name: title_arr.first)
end
FoodForecast::MstHealth.import(healthes)

=begin
weather_h_arr = []
FoodForecast::WeatherHealth.connection.execute("TRUNCATE TABLE #{FoodForecast::WeatherHealth.table_name}")
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "台風接近").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "だるい"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "台風接近").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "頭痛"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "台風接近").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "吐き気"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "台風接近").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "耳鳴り"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "台風接近").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "腰痛"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "湿度高").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "関節痛"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "湿度高").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "疲れやすさ"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "湿度高").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "だるい"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "湿度低").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "アトピー性皮膚炎"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "湿度低").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "体のかゆみ"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "気温が高い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "体のかゆみ"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "気温が高い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "血圧が上がる"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "気温が高い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "鼻がつまり"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "気温が低い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "下痢しやすい"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "気温が低い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "血液循環不良"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "気温が低い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "生理痛"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "気温が低い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "肩のこり"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "気温が低い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "冷え性"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "梅雨").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "ＰＭＳ(月経前症候群）"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "梅雨").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "肩こり"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "梅雨").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "だるい"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "紫外線が強い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "眼精疲労"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "紫外線が強い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "頭痛"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "紫外線が強い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "めまい"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "紫外線が強い").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "吐き気"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "PM2.5").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "目のかゆみ"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "PM2.5").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "くしゃみ、鼻水"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "PM2.5").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "のどの痛み"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "PM2.5").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "咳が出る"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "PM2.5").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "目の充血"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "寒暖の差が激しい").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "頭痛"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "寒暖の差が激しい").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "肩こり"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "寒暖の差が激しい").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "寒冷蕁麻疹"))

weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "強風").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "頭痛"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "強風").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "めまい"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "強風").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "耳鳴り"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "強風").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "気分が落ち着かない"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "強風").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "じんましん"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "強風").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "咳"))
weather_h_arr << FoodForecast::WeatherHealth.new(mst_weather_id: FoodForecast::MstWeather.find_by(name: "強風").id, mst_health_id: FoodForecast::MstHealth.find_by(name: "お肌の乾燥"))
FoodForecast::WeatherHealth.import(weather_h_arr)
=end

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