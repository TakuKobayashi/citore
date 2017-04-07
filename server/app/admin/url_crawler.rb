ActiveAdmin.register CrawlTargetUrl  do
  menu priority: 1, label: "Urlクローラー", parent: "data"

  config.batch_actions = true
  config.per_page = 100

  actions :index

  action_item(:index, only: :index) do
    link_to("クロールする", admin_urlcrawler_path, class: "table_tools_button")
  end

  index do
    id_column
    column("リンク") {|a| link_to(a.title.present? ? a.title : a.target_url, a.target_url) }
    column("クラス名") {|a| a.source_type }
    column("クロール済み?") {|a| a.crawled_at.present? }
  end
end

ActiveAdmin.register_page "UrlCrawler" do
  menu false

  content title: "Urlクローラー" do
    columns do
      column do
        link_to("一覧に戻る", admin_crawl_target_urls_path, class: "table_tools_button")
      end
    end
    columns do
      column do
        Rails.application.eager_load!
        models = ActiveRecord::Base.descendants.reject{|m| m.to_s.include?("Admin") || m.to_s.include?("ActiveRecord::") || m.abstract_class? }
        models_hash = {}
        models.each{|model| models_hash[model.to_s] = model.column_names.reject{|name| name == "id" || name == "created_at" || name == "updated_at" } }
        active_admin_form_for(:url, url: admin_urlcrawler_crawl_path) do |f|
          f.inputs do
            f.input :crawl_url, label: "クロールするサイトのURL"
            f.input :request_method, label: "リクエストメソッド", as: :select, collection: [:get, :post].map{|m| [m.to_s, m.to_s]}, selected: :get, include_blank: false
            f.input :filter, label: "該当の場所を絞りこむためのDOM要素"
            f.input :target_class, as: :select, collection: models.map{|m| [m.to_s, m.to_s]}, include_blank: true, label: "後でどのModelのデータに活用させるか"
            f.input :start_page_num, as: :number, label: "クロール開始ページ番号"
            f.input :end_page_num, as: :number, label: "クロール終了ページ番号"
            panel("以下には指定したModelのカラムに入れるデータのDOMを指定してください") do
              ol(id: "target_class_column_field") do
              end
            end
            f.submit("クロールする")
          end
          f.script do
            crawl_pull_down_script(models_hash)
          end
        end
      end
    end
  end

  page_action :crawl, method: :post do
    url = params[:url][:crawl_url]
    columns_dom = params[:url][:columns] || {}
    start_page = params[:url][:start_page_num].to_i
    end_page = params[:url][:end_page_num].to_i
    targets = []
    (start_page.to_i..end_page.to_i).each do |page|
      address_url = Addressable::URI.parse(url % page.to_s)
      doc = ApplicationRecord.request_and_parse_html(address_url.to_s, params[:url][:request_method])
      if params[:url][:filter].present?
        doc = doc.css(params[:url][:filter])
      end
      CrawlTargetUrl.transaction do
        doc.css("a").select{|anchor| anchor[:href].present? && anchor[:href] != "/" }.each do |d|
          link = Addressable::URI.parse(d[:href])
          if link.host.blank?
            if link.path.blank? || link.to_s.include?("javascript:")
              next
            end
            link.host = address_url.host
            link.scheme = address_url.scheme
          end
          title = d[:title] || d.text
          targets << CrawlTargetUrl.setting_target!(
            target_class_name: params[:url][:target_class].to_s,
            url: link.to_s,
            from_url: address_url.to_s,
            column_extension: columns_dom,
            title: ApplicationRecord.basic_sanitize(title.to_s) 
          )
        end
      end
    end
    redirect_to(admin_urlcrawler_path, notice: "#{url}から #{start_page}〜#{end_page}ページで 合計#{targets.size}件のリンクを取得しました")
  end
end