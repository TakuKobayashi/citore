ActiveAdmin.register Datapool::StoreProduct do
  menu priority: 1, label: "ストア情報", parent: "datapool"

  config.batch_actions = true
  config.per_page = 100

  actions :index, :show

  index do
    id_column
    column("ストア種別") {|a| a.type }
    column("ストアID") {|a| link_to(a.product_id, a.url) }
    column("タイトル") {|a| a.title }
    column("アイコン") {|a| image_tag(a.icon_url) }
    column("配信者名") {|a| a.publisher_name }
    column("配信日") {|a| a.published_at }
    column("レビュー数") {|a| a.review_count }
    column("平均レビュースコア") {|a| a.average_score }
  end

  show do
    panel datapool_store_product.title do
      attributes_table_for datapool_store_product do
        row("ID") {|a| a.id }
        row("ストア種別") {|a| a.type }
        row("ストアID") {|a| a.product_id }
        row("ストアURL") {|a| link_to(a.url) }
        row("タイトル") {|a| a.title }
        row("説明文") {|a| a.description.html_safe }
        row("アイコン") {|a| image_tag(a.icon_url) }
        row("配信者名") {|a| a.publisher_name }
        row("配信日") {|a| a.published_at }
        row("レビュー数") {|a| a.review_count }
        row("平均レビュースコア") {|a| a.average_score }
        row("その他") {|a| a.options }
        row("直近ランク") do |a|
          last_ranking = a.rankings.last
          last_ranking.category + "の#{last_ranking.rank}位"
        end
        row("直近レビュー") do |a|
          result = ""
          a.reviews.last(3).reverse.each_with_index do |review, i|
            result += [
              "レビュー#{i + 1}",
              "名前: #{review.title}",
              "スコア: #{review.score}",
              "タイトル: #{review.user_name}",
              "メッセージ: #{review.message}"].join("<br>")
            result += "<br><br>"
          end
          result.html_safe
        end
      end
    end
  end
end