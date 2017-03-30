ActiveAdmin.register TwitterBot  do
  menu priority: 0, label: "TwitterBot", parent: "サービス"

  actions :index, :show

  controller do
    def scoped_collection
      TwitterBot.includes(:approached)
    end
  end

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