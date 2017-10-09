ActiveAdmin.register Datapool::VideoMetum do
  menu priority: 1, label: "動画クローラー", parent: "datapool"

  config.batch_actions = true
  config.per_page = 100

  actions :index

  action_item(:crawl, only: :index) do
    link_to("クロールする", tools_image_crawl_path, class: "table_tools_button")
  end

  index do
    id_column
    column("タイトル") {|a| a.title }
    column("クラス名") {|a| a.type }
    column("動画") {|a| video_tag(a.src, width: 200) }
  end
end