ActiveAdmin.register CrawlTargetUrl  do
  menu priority: 1, label: "Urlクローラー", parent: "data"

  config.batch_actions = true
  config.per_page = 100

  actions :index

  index do
    div link_to("クロールする", admin_urlcrawler_path, class: "table_tools_button")
    br
    id_column
    column("リンク") {|a| link_to(a.target_url, a.target_url) }
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
            f.input :target_class, as: :select, collection: models.map{|m| [m.to_s, m.to_s]}, include_blank: false, label: "後でどのModelのデータに活用させるか"
            div(id: "target_class_column_field")
            f.submit("クロールする")
          end
          f.script do
            %Q{
              var model_columns = #{models_hash.to_json}
              console.log(model_columns);
              $(document).ready(function(){
                var column_list_field = $("#target_class_column_field");
                console.log(column_list_field);
                $('#url_target_class').change(function(obj){
                  var selectClassName = $(this).val();
                  var list = model_columns[selectClassName];
                  column_list_field.empty();
                  for(var i = 0;i < list.length;++i){
                    column_list_field.append(
                      $('<li class="select input required" id="url_' + list[i] + '_input">').append(
                        '<label for="' + list[i] + '" class="label">' + list[i] + '</label>',
                        '<input id="url_' + list[i] + '" type="text" name="url[columns][' + list[i] + ']">'
                      )
                    );
                  }
                });
              });
            }.html_safe
          end
        end
      end
    end
  end

  page_action :crawl, method: :post do
    url = params[:url][:crawl_url]
    columns_dom = params[:url][:columns] || {}
    address_url = Addressable::URI.parse(url)
    doc = ApplicationRecord.request_and_parse_html(url, params[:url][:request_method])
    targets = []
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
        targets << CrawlTargetUrl.setting_target!(params[:url][:target_class].to_s, link.to_s, url)
      end
    end
    redirect_to(admin_urlcrawler_path, notice: "#{url}から #{targets.size}件のリンクを取得しました")
  end
end