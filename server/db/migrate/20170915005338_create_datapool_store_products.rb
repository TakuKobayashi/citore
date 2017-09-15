class CreateDatapoolStoreProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_store_products do |t|
      t.string :type
      t.string :publisher_name
      t.string :product_id, null: false
      t.string :title, null: false
      t.text :description
      t.text :url, null: false
      t.string :icon_url
      t.integer :review_count, null: false, default: 0
      t.float :average_score, null: false, default: 0
      t.datetime :published_at
      t.text :options
    end

    add_index :datapool_store_products, [:product_id, :type], name: "store_product_unique_index", unique: true
    add_index :datapool_store_products, :published_at, name: "store_product_published_at_index"
  end
end
