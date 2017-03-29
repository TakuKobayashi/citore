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
        active_admin_form_for(:url, url: admin_urlcrawler_crawl_path) do |f|
          f.inputs do
            f.input :crawl_url, label: "クロールするサイトのURL"
            f.input :request_method, label: "リクエストメソッド", as: :select, collection: [:get, :post].map{|m| [m.to_s, m.to_s]}, selected: :get, include_blank: false
            f.input :filter, label: "該当の場所を絞りこむためのDOM要素"
            f.input :target_class, label: "後でどのModelのデータに活用させるか"
            f.submit("クロールする")
          end
          f.script do
            %Q{
              $(document).ready(function(){
                area_change();
                disable_category();
              });

              $('[id^=opr_coupon_category]').on("change", function(){
                area_change();
              });

              var area_change = function(){
                $("#opr_coupon_shared_code_input").hide();
                $("#opr_coupon_limit_input").hide();
                $("#unique_code_input").hide();
                $("#opr_coupon_import_serial_input").hide();

                if ($("#opr_coupon_category_shared").prop("checked")){
                  $("#opr_coupon_shared_code_input").show();
                } else if($("#opr_coupon_category_unique").prop("checked")) {
                  $("#opr_coupon_limit_input").show();
                  $("#unique_code_input").show();
                  if ("#{action_name}" == "new") {
                    $("#opr_coupon_import_serial_input").show();
                  }
                }
              }

              var disable_category = function(){
                if ("#{action_name}" == "edit"){
                  $('[id^=opr_coupon_category]').prop("disabled", true);
                }
              }
            }.html_safe
          end
        end
      end
    end
  end

  page_action :crawl, method: :post do
    url = params[:url][:crawl_url]
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