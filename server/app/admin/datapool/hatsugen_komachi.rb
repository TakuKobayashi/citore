ActiveAdmin.register Datapool::HatsugenKomachi do
  menu priority: 1, label: "発言小町", parent: "datapool"

  config.batch_actions = true
  config.per_page = 100

  actions :index, :show

  index do
    id_column
    column("タイトル") {|a| a.title }
    column("トピックID") {|a| a.topic_id }
    column("投稿日時") {|a| a.posted_at }
    column("反応") {|a| "面白い:#{a.funny} びっくり:#{a.surprise} 涙ぽろり:#{a.tears} エール:#{a.yell} なるほど:#{a.isee}" }
    column("ジャンルコード") {|a| a.genre_code }
  end

  show do
    panel datapool_hatsugen_komachi.topic_id do
      attributes_table_for datapool_hatsugen_komachi do
        row("ID") {|a| a.id }
        row("タイトル") {|a| a.title }
        row("返信番号") {|a| a.res_number }
        row("トップフラグ") {|a| a.top_res_flag }
        row("投稿日時") {|a| a.posted_at }
        row("投稿者名") {|a| a.handle_name }
        row("本文") {|a| a.body.html_safe }
        row("備考") {|a| a.advice }
        row("面白い") {|a| a.funny }
        row("びっくり") {|a| a.surprise }
        row("涙ぽろり") {|a| a.tears }
        row("エール") {|a| a.yell }
        row("なるほど") {|a| a.isee }
        row("ジャンルコード") {|a| a.genre_code }
        row("res_state") {|a| a.res_state }
        row("facemark_id") {|a| a.facemark_id }
        row("remark") {|a| a.remark }
        row("post_device") {|a| a.post_device }
        datapool_hatsugen_komachi.keywords.each_with_index do |keyword, index|
          row("キーワード#{index + 1}") {|a| a.word }
          row("キーワード#{index + 1}品詞") {|a| a.part }
          row("キーワード#{index + 1}スコア") {|a| "出現回数#{a.appear_score} tf-idf:#{a.tf_idf_score}" }
        end
      end
    end
  end
end