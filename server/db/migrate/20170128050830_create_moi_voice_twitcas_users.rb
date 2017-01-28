class CreateMoiVoiceTwitcasUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :moi_voice_twitcas_users do |t|
      t.string :twitcas_user_id, null: false
      t.string :name
      t.text :access_token
      t.integer :expires_in, null: false, default: 0
      t.datetime :last_logined_at, null: false
      t.timestamps
    end
    add_index :moi_voice_twitcas_users, :twitcas_user_id, unique: true
  end
end
