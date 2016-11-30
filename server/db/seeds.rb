# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

dics = []

en = File.read(Rails.root.to_s + "/scripts/dictionary/pn_en.dic")
ens = en.split("\n")
ens.each do |e|
  es = e.split(":")
  dic = EmotionalWordDynamo.find(word: es[0], reading: es[0], part: es[1])
  next if dic.present?
  dic = EmotionalWordDynamo.new
  dic.word = es[0]
  dic.reading = es[0]
  dic.part = es[1]
  dic.score = es[2].to_f
  dic.save!
  p "w:#{es[0]} r:#{es[0]} p:#{es[1]} s:#{es[2]}"
end

parts = EmotionalWordDictionary::PARTS
ja = File.read(Rails.root.to_s + "/scripts/dictionary/pn_ja.dic")
jas = ja.split("\r\n")
jas.each do |j|
  js = j.split(":")
  dic = EmotionalWordDynamo.find(word: js[0], reading: js[1])
  next if dic.present?
  dic = EmotionalWordDictionary.new
  dic.word = js[0]
  dic.reading = js[1]
  dic.part = parts[js[2]]
  dic.score = js[3].to_f
  p "w:#{js[0]} r:#{js[1]} p:#{js[2]} s:#{js[3]}"
  dic.save!
end

ens_average_score = ens.inject(0){|result, cell| result += cell.split(":")[2].to_f} / ens.size
jas_average_score = jas.inject(0){|result, cell| result += cell.split(":")[3].to_f} / jas.size

json = {}
json[:en_average_score] = ens_average_score
json[:ja_average_score] = jas_average_score
json[:crawl_info] = []
json[:crawl_info] << {state: CrawlScheduler.states[:pending], search_action: "user_timeline", keyword: "citore", search_word: TweetSeed::ERO_KOTOBA_BOT, uuid: SecureRandom.hex}
json[:crawl_info] << {state: CrawlScheduler.states[:pending], search_action: "user_timeline", keyword: "citore", search_word: TweetSeed::AEGIGOE_BOT, uuid: SecureRandom.hex}
json[:crawl_info] << {state: CrawlScheduler.states[:pending], search_action: "search", keyword: "sugarcoat", search_word: "オブラート", uuid: SecureRandom.hex}
json[:crawl_info] << {state: CrawlScheduler.states[:pending], search_action: "search", keyword: "sugarcoat", search_word: "#言い方", uuid: SecureRandom.hex}
File.open("tmp/extra_info.json", "w"){|f| f.write(json.to_json) }