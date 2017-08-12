class CreateHomepageProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :homepage_products do |t|
      t.integer :category, null: false, default: 0
      t.string :title, null: false
      t.text :description
      t.string :thumbnail_url
      t.string :large_image_url
      t.string :url
      t.datetime :pubulish_at, null: false
      t.timestamps
    end
    add_index :homepage_products, :pubulish_at
  end
end
