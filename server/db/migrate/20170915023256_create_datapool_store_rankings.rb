class CreateDatapoolStoreRankings < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_store_rankings do |t|
      t.integer :datapool_store_product_id, null: false
      t.integer :category, null: false, default: 0
      t.integer :rank, null: false, default: 0
      t.timestamps
    end
    add_index :datapool_store_rankings, :datapool_store_product_id, name: "store_rankings_product_id_index"
    add_index :datapool_store_rankings, :created_at, name: "store_rankings_created_at_index"
  end
end
