class CreateHomepageProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :homepage_products do |t|
      t.integer :category, null: false, default: 0
      t.string :title
      t.text :html_body, null: false
      t.string :url
      t.datetime :pubulish_at, null: false
      t.timestamps
    end
  end
end
