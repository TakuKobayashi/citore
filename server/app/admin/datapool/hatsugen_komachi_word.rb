ActiveAdmin.register Datapool::HatsugenKomachiWord  do
  menu priority: 1, label: "発言小町での出現した単語", parent: "datapool"

  config.batch_actions = true
  config.per_page = 100

  actions :index

  index do
    id_column
    column("タイプ") {|a| a.type }
    column("単語") {|a| a.word }
    column("品詞") {|a| a.part }
    column("読み") {|a| a.reading }
    column("のべ出現回数") {|a| a.appear_count }
    column("出現文章数") {|a| a.sentence_count }
  end
end