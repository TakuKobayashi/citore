class AddColumnToBannosamaUser < ActiveRecord::Migration[5.1]
  def change
    add_column :bannosama_users, :user_agent, :text
  end
end
