ActiveAdmin.register LinebotFollowerUser  do
  menu priority: 0, label: "Lineユーザー", parent: "サービス"

  actions :index, :show

  index do
    id_column
    column("クラス名") {|a| a.type }
    column("LineId") {|a| a.line_user_id }
    column("名前") {|a| a.display_name }
    column("画像") {|a| image_tag(a.picture_url) }
    column("LineId") {|a| a.line_user_id }
    column("紹介文") {|a| a.status_message }
    column("フォローしてくれていない?") {|a| a.unfollow }
    column("登録日") {|a| a.created_at }
    actions
  end
end