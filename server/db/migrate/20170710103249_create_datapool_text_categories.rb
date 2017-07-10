class CreateDatapoolTextCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_text_categories do |t|
      t.integer :datapool_text_id, null: false
      t.integer :datapool_category_id, null: false
    end
    add_index :datapool_text_categories, [:datapool_text_id, :datapool_category_id], name: "datapool_text_category_relation_index", unique: true
  end
end
