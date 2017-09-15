class CreateDatapoolReviews < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_reviews do |t|
      t.integer :datapool_store_product_id
      t.string :user_name
      t.float :score, null: false, default: 0
      t.text :message, null: false
      t.text :options
    end
    add_index :datapool_reviews, :datapool_store_product_id, name: "reviews_product_url_index"
  end
end
