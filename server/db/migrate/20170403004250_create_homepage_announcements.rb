class CreateHomepageAnnouncements < ActiveRecord::Migration[5.0]
  def change
    create_table :homepage_announcements do |t|
      t.string :title
      t.text :html_body, null: false
      t.string :url
      t.datetime :pubulish_at, null: false
      t.timestamps
    end
    add_index :homepage_announcements, :pubulish_at
  end
end
