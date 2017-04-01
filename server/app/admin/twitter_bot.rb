ActiveAdmin.register TwitterBot  do
  menu priority: 0, label: "TwitterBot", parent: "サービス"

  includes :approached

  actions :index, :show

  index do
    id_column
    column("クラス名") {|a| a.type }
    column("Action名") {|a| a.action }
    column("やったこと") {|a| a.action_value }
    column("やった時間") {|a| a.action_time }
    column("されたAction名") {|a| a.approached.try(:action) }
    column("されたこと") {|a| a.approached.try(:tweet) }
    actions
  end
end