ActiveAdmin.register_page "LinkChecker" do
  menu priority: 1, label: "リンクチェック", parent: "debug"

  content title: "URL確認用" do
    active_admin_form_for(:register, url: admin_linkchecker_register_url) do |f|
      f.inputs do
        f.input :url, as: :string, label: "urlを入力する"
        f.submit
      end
    end

    panel "link一覧" do
      table do
        th "url"
        urls = ExtraInfo.read_extra_info["check_link_urls"] || []
        urls.each do |url|
          tr do
            td link_to(url, url)
            td link_to("削除する", admin_linkchecker_remove_url(url: url))
          end
        end
      end
    end
  end

  page_action :register, method: :post do
    urls = ExtraInfo.read_extra_info["check_link_urls"] || []
    urls << params[:register][:url]
    ExtraInfo.update({"check_link_urls" => urls.compact.uniq})
    redirect_to(admin_linkchecker_url, notice: "urlを追加しました")
  end

  page_action :remove, method: :get do
    urls = ExtraInfo.read_extra_info["check_link_urls"] || []
    urls.reject!{|url| url == params[:url]}
    ExtraInfo.update({"check_link_urls" => urls.compact.uniq})
    redirect_to(admin_linkchecker_url, notice: "urlを削除しました")
  end
end