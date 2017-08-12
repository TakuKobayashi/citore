class CreateHomepageAccesses < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_accesses do |t|
      t.string :ip_address, null: false
      t.string :uid, null: false
      t.text :user_agent
      t.timestamps
    end
    add_index :homepage_accesses, :uid, unique: true
    add_index :homepage_accesses, :ip_address
  end
end
