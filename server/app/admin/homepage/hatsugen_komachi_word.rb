ActiveAdmin.register Homepage::UploadJobQueue  do
  menu priority: 1, label: "非同期ジョブの情報", parent: "homepage"

  config.batch_actions = true
  config.per_page = 100

  actions :index, :show, :edit, :update

  index do
    id_column
    column("タイプ") {|a| a.from_type }
    column("state") {|a| I18n.t("activerecord.enum.homepage_upload_job_queues.state.#{a.state}") }
    column("アップロードされた先") {|a| link_to(a.upload_url) }
    column("ファイルサイズ(Byte)") {|a| a.upload_file_size }
  end
end