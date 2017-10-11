ActiveAdmin.register Homepage::Announcement  do
  menu priority: 1, label: "アナウンス", parent: "homepage"

  config.batch_actions = true
  config.per_page = 100

  actions :index, :show, :edit, :update, :new, :create

  index do
    id_column
    column("タイトル") {|a| a.title }
    column("type") {|a| a.from_type }
    column("typeId") {|a| a.from_id }
    column("url") {|a| link_to(a.url) }
    column("公開日時") {|a| a.pubulish_at }
  end
end