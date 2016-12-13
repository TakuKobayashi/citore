class CreateWikipediaCategoryPages < ActiveRecord::Migration[5.0]
  def change
    create_table :wikipedia_category_pages do |t|
      t.integer :wikipedia_page_id, null: false, default: 0
      t.string :category_title, null: false, default: ''
      t.string :sortkey, null: false, default: ''
      t.datetime :timestamp
      t.string :sortkey_prefix, null: false, default: ''
      t.string :collation, null: false, default: '' 
      t.integer :category_type, null: false, default: 0
    end
    add_index :wikipedia_category_pages, [:wikipedia_page_id, :category_title], unique: true, name: "from_to"
    add_index :wikipedia_category_pages, [:category_title, :timestamp]
    add_index :wikipedia_category_pages, [:category_title, :category_type, :sortkey, :wikipedia_page_id], name: "sortkey"
    add_index :wikipedia_category_pages, [:collation, :category_title, :category_type, :wikipedia_page_id], name: "collation_ext"
  end
end
