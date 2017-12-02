class CreateHackathonSunflowerUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_sunflower_users do |t|
      t.string :name
      t.string :token, null: false
      t.string :phone_number
      t.string :email
      t.integer :reservation_number, null: false, default: 0
      t.timestamps
    end
    add_index :hackathon_sunflower_users, :token
    add_index :hackathon_sunflower_users, :phone_number
    add_index :hackathon_sunflower_users, :email
  end
end
