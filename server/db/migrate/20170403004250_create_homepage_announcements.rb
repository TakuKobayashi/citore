class CreateHomepageAnnouncements < ActiveRecord::Migration[5.0]
  def change
    create_table :homepage_announcements do |t|
      t.string :title, null: false
      t.string :from_type
      t.integer :from_id
      t.text :description
      t.string :url
      t.datetime :pubulish_at, null: false
      t.timestamps
    end
    add_index :homepage_announcements, [:from_type, :from_id]
    add_index :homepage_announcements, :pubulish_at
  end
end
