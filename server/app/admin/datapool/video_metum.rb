ActiveAdmin.register Datapool::VideoMetum do
  menu priority: 1, label: "動画クローラー", parent: "datapool"

  config.batch_actions = true
  config.per_page = 100

  actions :index, :show

  action_item(:crawl, only: :index) do
    link_to("クロールする", tools_image_crawl_path, class: "table_tools_button")
  end

  index do
    id_column
    column("タイトル") {|a| a.title }
    column("クラス名") {|a| a.type }
    column("動画の表紙画像") {|a| image_tag(a.front_image_url, width: 200) }
  end

  show do
    panel datapool_video_metum.title do
      attributes_table_for datapool_video_metum do
        row("ID") {|a| a.id }
        row("クラス名") {|a| a.type }
        row("データ種別") {|a| a.data_category }
        row("ビットレート") {|a| a.bitrate }
        row("動画の表紙画像") {|a| image_tag(a.front_image_url) }
        row("動画") {|a| video_tag(a.src) }
        row("その他情報") {|a| a.options }
      end
    end
  end
end