class CreateHomepageLikes < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_likes do |t|
      t.string :from_type, null: false
      t.integer :from_id, null: false
      t.integer :homepage_access_id, null: false
      t.timestamps
    end
    add_index :homepage_likes, [:from_type, :from_id, :homepage_access_id], unique: true, name: "homepage_likes_primary_index"
    add_index :homepage_likes, :homepage_access_id
  end
end
