class CreateLinebotFollowerUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :linebot_follower_users do |t|
      t.string :type, null: false
      t.string :line_user_id, null: false
      t.string :display_name, null: false
      t.string :picture_url
      t.text :status_message
      t.boolean :unfollow, null: false, default: true
      t.timestamps
    end
    add_index :linebot_follower_users, [:line_user_id, :type], unique: true
  end
end
