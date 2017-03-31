ActiveAdmin.register_page "TextCrawler" do
  menu priority: 1, label: "文章クローラー", parent: "data"

  content title: "文章クローラー" do
    columns do
      column do
        Rails.application.eager_load!
        models = ActiveRecord::Base.descendants.reject{|m| m.to_s.include?("Admin") || m.to_s.include?("ActiveRecord::") || m.abstract_class? }
        models_hash = {}
        models.each{|model| models_hash[model.to_s] = model.column_names.reject{|name| name == "id" || name == "created_at" || name == "updated_at" } }
        active_admin_form_for(:text, url: admin_textcrawler_crawl_path) do |f|
          f.inputs do
            f.input :crawl_url, label: "クロールするサイトのURL"
            f.input :request_method, label: "リクエストメソッド", as: :select, collection: [:get, :post].map{|m| [m.to_s, m.to_s]}, selected: :get, include_blank: false
            f.input :filter, label: "該当の場所を絞りこむためのDOM要素"
            f.input :target_class, as: :select, collection: models.map{|m| [m.to_s, m.to_s]}, include_blank: true, label: "後でどのModelのデータに活用させるか"
            f.input :start_page_num, as: :number, label: "クロール開始ページ番号"
            f.input :end_page_num, as: :number, label: "クロール終了ページ番号"
            div(id: "target_class_column_field")
            f.submit("クロールする")
          end
          f.script do
            %Q{
              var model_columns = #{models_hash.to_json}
              $(document).ready(function(){
                var column_list_field = $("#target_class_column_field");
                $('#text_target_class').change(function(obj){
                  var selectClassName = $(this).val();
                  var list = model_columns[selectClassName];
                  column_list_field.empty();
                  if(!list){
                    return;
                  }
                  for(var i = 0;i < list.length;++i){
                    column_list_field.append(
                      $('<li class="select input required" id="url_' + list[i] + '_input">').append(
                        '<label for="' + list[i] + '" class="label">' + list[i] + '</label>',
                        '<input id="text_' + list[i] + '" type="text" name="text[columns][' + list[i] + ']">'
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
    url = params[:text][:crawl_url]
    columns_dom = params[:text][:columns] || {}
    start_page = params[:text][:start_page_num].to_i
    end_page = params[:text][:end_page_num].to_i
    targets = []
    clazz = (params[:text][:target_class].to_s).constantize
    clazz.transaction do
      (start_page.to_i..end_page.to_i).each do |page|
        address_url = Addressable::URI.parse(url % page.to_s)
        doc = ApplicationRecord.request_and_parse_html(address_url.to_s, params[:text][:request_method])
        if params[:text][:filter].present?
          doc = doc.css(params[:text][:filter])
        end
        doc.each do |d|
          clazz_instance = clazz.new
          columns_dom.each do |key, dom|
            if dom.present?
              crawl_text = d.css(dom).text
            else
              next
            end
            logger.info dom.text
            clazz_instance.send(key + "=", ApplicationRecord.basic_sanitize(crawl_text))
          end
          targets << clazz_instance
        end
      end
      clazz.import(targets)
    end
    redirect_to(admin_textcrawler_path, notice: "#{url}から #{start_page}〜#{end_page}ページで 合計#{targets.size}件のリンクを取得しました")
  end
end