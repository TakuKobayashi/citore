ActiveAdmin.register Homepage::Article  do
  menu priority: 1, label: "記事", parent: "homepage"

  config.batch_actions = true
  config.per_page = 100

  actions :index, :show, :edit, :update, :new, :create

  index do
    id_column
    column("タイトル") {|a| a.title }
    column("タイプ") {|a| a.type }
    column("uid") {|a| a.uid }
    column("url") {|a| link_to(a.url) }
    column("thumbnail") {|a| image_tag(a.thumbnail_url) }
    column("有効か") {|a| a.active }
    column("公開日時") {|a| a.pubulish_at }
  end
end