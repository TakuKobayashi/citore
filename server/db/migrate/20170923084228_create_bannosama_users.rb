class CreateBannosamaUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :bannosama_users do |t|
      t.string :type
      t.string :name
      t.string :thumnail_image_url
      t.string :uuid, null: false
      t.timestamps
    end
    add_index :bannosama_users, :uuid, unique: true
  end
end
