ActiveAdmin.register ImageMetum  do
  menu priority: 1, label: "画像クローラー", parent: "data"

  config.batch_actions = true
  config.per_page = 100

  actions :index

  index do
    div link_to("クロールする", admin_imagecrawler_path, class: "table_tools_button")
    br
    id_column
    column("タイトル") {|a| a.title }
    column("クラス名") {|a| a.type }
    column("画像") {|a| image_tag(a.file_url) }
  end
end

ActiveAdmin.register_page "ImageCrawler" do
  menu false

  content title: "画像クローラー" do
    columns do
      column do
        link_to("一覧に戻る", admin_image_meta_path, class: "table_tools_button")
      end
    end
    columns do
      column do
        active_admin_form_for(:image, url: admin_imagecrawler_crawl_path) do |f|
          f.inputs do
            f.input :crawl_url, label: "クロールするサイトのURL"
            f.input :request_method, label: "リクエストメソッド", as: :select, collection: [:get, :post].map{|m| [m.to_s, m.to_s]}, selected: :get, include_blank: false
            f.input :filter, label: "該当の場所を絞りこむためのDOM要素"
            f.input :target_class, label: "保存する対象のclassがあれば選ぶ"
            f.submit("クロールする")
          end
        end
      end
    end
  end

  page_action :crawl, method: :post do
    url = params[:image][:crawl_url]
    doc = ApplicationRecord.request_and_parse_html(url, params[:image][:request_method])
    if params[:image][:filter].present?
      doc = doc.css(params[:image][:filter])
    end
    images = []
    doc.css("img").each do |d|
      images << ImageMetum.new(type: params[:image][:target_class], title: d[:title].to_s, url: d[:src])
    end
    ImageMetum.import(images)
    redirect_to(admin_imagecrawler_path, notice: "#{url}から #{images.size}件の画像を取得しました")
  end
end