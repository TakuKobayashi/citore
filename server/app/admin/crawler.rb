ActiveAdmin.register_page "Crawler" do
  menu priority: 1, label: "クローラー", parent: "data"

  content title: "クローラー" do
    panel "画像クローラー" do
      active_admin_form_for(:image, url: admin_crawler_image_crawl_path) do |f|
        f.inputs do
          f.input :crawl_url, label: "クロールするサイトのURL"
          f.input :request_method, label: "リクエストメソッド", as: :select, collection: [:get, :post].map{|m| [m.to_s, m.to_s]}, selected: :get, include_blank: false
          f.input :filter, label: "該当の場所を絞りこむためのDOM要素"
          f.input :target_class, label: "保存する対象のclassがあれば選ぶ"
          f.submit
        end
      end
    end

    panel "リンククローラー" do
      active_admin_form_for(:url, url: admin_crawler_url_crawl_path) do |f|
        f.inputs do
          f.input :crawl_url, label: "クロールするサイトのURL"
          f.input :request_method, label: "リクエストメソッド", as: :select, collection: [:get, :post].map{|m| [m.to_s, m.to_s]}, selected: :get, include_blank: false
          f.input :filter, label: "該当の場所を絞りこむためのDOM要素"
          f.input :target_class, label: "後でどのModelのデータに活用させるか"
          f.submit
        end
      end
    end
  end

  page_action :image_crawl, method: :post do
    url = params[:image][:crawl_url]
    doc = ApplicationRecord.request_and_parse_html(url, params[:image][:request_method])
    if params[:image][:filter].present?
      doc = doc.css(params[:image][:filter])
    end
    images = []
    doc.css("img").each do |d|
      images << ImageMetum.new(type: params[:image][:target_class], title: d[:title].to_s, url: d[:src])
    end
    p images
    ImageMetum.import(images)
    redirect_to(admin_crawler_path, notice: "#{url}から #{images.size}件の画像を取得しました")
  end

  page_action :url_crawl, method: :post do
    url = params[:url][:crawl_url]
    address_url = Addressable::URI.parse(url)
    doc = ApplicationRecord.request_and_parse_html(url, params[:url][:request_method])
    targets = []
    doc.css("a").select{|anchor| anchor[:href].present? && anchor[:href] != "/" }.each do |d|
      link = Addressable::URI.parse(d[:href])
      if link.host.blank?
        if link.path.blank? || link.to_s.include?("javascript:")
          next
        end
        link.host = address_url.host
      end
      targets << CrawlTargetUrl.setting_target!(params[:url][:target_class].to_s, link.to_s, d[:title].to_s)
    end
    redirect_to(admin_crawler_path, notice: "#{url}から #{targets.size}件のリンクを取得しました")
  end
end