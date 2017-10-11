ActiveAdmin.register Homepage::Product  do
  menu priority: 1, label: "制作物", parent: "homepage"

  config.batch_actions = true
  config.per_page = 100

  actions :index, :show, :edit, :update, :new, :create

  index do
    id_column
    column("タイトル") {|a| a.title }
    column("カテゴリ") {|a| a.category }
    column("thumbnail") {|a| image_tag(a.thumbnail_url) }
    column("url") {|a| link_to(a.url) }
    column("公開日時") {|a| a.pubulish_at }
  end
end