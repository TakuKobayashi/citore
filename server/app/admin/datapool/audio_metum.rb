ActiveAdmin.register Datapool::AudioMetum do
  menu priority: 1, label: "サウンドクローラー", parent: "datapool"

  config.batch_actions = true
  config.per_page = 100

  actions :index

  action_item(:crawl, only: :index) do
    link_to("クロールする", crawl_tools_audio_path, class: "table_tools_button")
  end

  index do
    id_column
    column("タイトル") {|a| a.title }
    column("クラス名") {|a| a.type }
    column("音声") {|a| audio_tag(a.src, controls: true) }
  end
end