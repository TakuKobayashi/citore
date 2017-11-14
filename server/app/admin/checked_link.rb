ActiveAdmin.register_page "LinkChecker" do
  content title: "URL確認用" do
    panel "エクセルまたはCSVのデータをインポート" do
      active_admin_form_for(:register, url: admin_databatches_import_data_path) do |f|
        f.inputs do
          f.input :url, as: :text, label: "ファイルを選択"
          f.input :before_truncate, as: :check_boxes, collection: ["Yes"], label: "インポートする前にデータベースを空にする?"
          f.submit
        end
      end
    end

    panel "link一覧" do
      columns do
        urls = ExtraInfo.read_extra_info["check_link_urls"] || []
        urls.each do |url|
          column do
            link_to(url, url)
          end
          column do
            link_to("削除する", url)
          end
        end
      end
    end
  end

  page_action :register, method: :post do
    redirect_to(active_admin_log_mst_imports_path, notice: "#{file.original_filename} importしました")
  end

  page_action :remove, method: :get do
    redirect_to(active_admin_log_mst_imports_path, notice: "アップロード開始")
  end
end