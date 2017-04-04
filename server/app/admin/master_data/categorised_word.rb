ActiveAdmin.register CategorisedWord  do
  menu priority: 1, label: "様々に分類された文章", parent: "master_data"

  config.batch_actions = false
  config.per_page = 100

  filter :type

  index do
    id_column
    column("クラス名") {|a| a.type }
    column("大分類") {|a| a.large_category }
    column("中分類") {|a| a.medium_category }
    column("詳細な分類") {|a| a.detail_category }
    column("本文") {|a| a.body }
    column("補足説明") {|a| a.description }
    actions
  end
end