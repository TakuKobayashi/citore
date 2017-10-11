ActiveAdmin.register Homepage::Tool do
  menu priority: 1, label: "Webツール", parent: "homepage"

  config.batch_actions = true
  config.per_page = 100

  actions :index, :show, :edit, :update, :new, :create

  index do
    id_column
    column("タイトル") {|a| a.title }
    column("url") {|a| link_to(a.path) }
    column("有効か") {|a| a.active }
    column("公開日時") {|a| a.pubulish_at }
  end
end