class CreateDatapoolCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_categories do |t|
      t.string :name, null: false
      t.integer :defined_number, null: false, default: 0
      t.integer :parent_category_id
    end
    add_index :datapool_categories, :name, unique: true
    add_index :datapool_categories, :defined_number
    add_index :datapool_categories, :parent_category_id
  end
end
