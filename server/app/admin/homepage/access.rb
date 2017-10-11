ActiveAdmin.register Homepage::Access do
  menu priority: 1, label: "訪問者情報", parent: "homepage"

  config.batch_actions = true
  config.per_page = 100

  actions :index

  index do
    id_column
    column("IPAdress") {|a| a.ip_address }
    column("useragent") {|a| a.user_agent }
  end
end