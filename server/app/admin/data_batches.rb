ActiveAdmin.register_page "DataBatches" do
  menu priority: 0, label: "データベース操作", parent: "data"

  content title: "データベース操作" do
    panel "エクセルまたはCSVのデータをインポート" do
      active_admin_form_for(:import, url: admin_databatches_import_data_path) do |f|
        f.inputs do
          f.input :file, as: :file, label: "ファイルを選択"
          f.input :before_truncate, as: :check_boxes, collection: ["Yes"], label: "インポートする前にデータベースを空にする?"
          f.submit
        end
      end
    end

    panel "DBのデータをS3にアップロード" do
      active_admin_form_for(:upload_to_s3, url: admin_databatches_upload_to_db_dump_to_s3_path) do |f|
        f.inputs do
          f.submit
        end
      end
    end
  end

  page_action :import_data, method: :post do
    file = params[:import][:file]
    clazz = (File.basename(file.original_filename, ".xls").
      singularize.
      gsub(/citore_/, 'citore/').
      gsub(/exam_/, 'exam/').
      gsub(/mone_/, 'mone/').
      gsub(/job_with_life_/, 'job_with_life/').
      gsub(/shiritori_/, 'shiritori/').
      gsub(/spot_gacha_/, 'spot_gacha/').
      gsub(/sugarcoat_/, 'sugarcoat/').
      camelcase).constantize

    if params[:import][:before_truncate].include?("Yes")
      clazz.connection.execute("TRUNCATE TABLE #{clazz.table_name}")
    end

    data = CSV.read(file.tempfile.path, headers: true)
    arr = data.map{|d| clazz.new(data) }
    ActiveRecord::Base.transaction do
      clazz.import(arr)
    end
    redirect_to(active_admin_log_mst_imports_path, notice: "#{file.original_filename} importしました")
  end

  page_action :upload_to_db_dump_to_s3, method: :post do
    system('bundle exec rake cron_batch:db_dump_and_upload')
    redirect_to(active_admin_log_mst_imports_path, notice: "アップロード開始")
  end
end