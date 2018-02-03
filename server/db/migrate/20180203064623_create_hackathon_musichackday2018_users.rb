class CreateHackathonMusichackday2018Users < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_musichackday2018_users do |t|
      t.string :token, null: false
      t.datetime :last_accessed_at, null: false
      t.text :user_agent
      t.text :options
      t.timestamps
    end
    add_index :hackathon_musichackday2018_users, :token, unique: true
    add_index :hackathon_musichackday2018_users, :last_accessed_at
  end
end
