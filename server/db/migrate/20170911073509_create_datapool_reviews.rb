class CreateDatapoolReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_reviews do |t|
      t.string :type
      t.string :title, null: false
      t.float :score, null: false, default: 0
      t.text :message, null: false
      t.string :product_id, null: false
      t.string :user_name
      t.string :product_url, null: false
      t.text :options
    end
    add_index :datapool_reviews, [:product_id, :type], name: "reviews_unique_product_index"
    add_index :datapool_reviews, :product_url, name: "reviews_product_url_index"
  end
end
