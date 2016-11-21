# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

dics = []

EmotionalWordDictionary.connection.execute("TRUNCATE TABLE #{EmotionalWordDictionary.table_name}")

en = File.read(Rails.root.to_s + "/scripts/dictionary/pn_en.dic")
ens = en.split("\n")
ens.each do |e|
  es = e.split(":")
  dic = EmotionalWordDynamo.new({
    word: es[0],
    part: es[1],
    info: {
      reading: es[0],
      score: es[2].to_f
    }
  })
  dic.save!

#  dic = EmotionalWordDictionary.new
#  dic.word = es[0]
#  dic.reading = es[0]
#  dic.part = es[1]
#  dic.score = es[2]
#  dics << dic
  puts dic.to_json if dic.part.nil?
end

parts = EmotionalWordDictionary::PARTS
ja = File.read(Rails.root.to_s + "/scripts/dictionary/pn_ja.dic")
jas = ja.split("\r\n")
jas.each do |j|
  js = j.split(":")
  dic = EmotionalWordDynamo.new({
    word: js[0],
    part: parts[js[2]],
    info: {
      reading: js[1],
      score: js[3].to_f
    }
  })
  dic.save!
#  dic = EmotionalWordDictionary.new
#  dic.word = js[0]
#  dic.reading = js[1]
#  dic.part = parts[js[2]]
#  dic.score = js[3]
#  dics << dic
  puts dic.to_json if dic.part.nil?
end

# EmotionalWordDictionary.import(dics)