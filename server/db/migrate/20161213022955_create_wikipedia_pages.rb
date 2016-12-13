class CreateWikipediaPages < ActiveRecord::Migration[5.0]
  def change
    create_table :wikipedia_pages do |t|
      t.integer :namespace, null: false, default: 0
      t.string :title, null: false, default: ''
      t.string :restrictions, null: false, default: ''
      t.integer :counter, limit: 8, null: false, default: 0
      t.boolean :is_redirect, null: false, default: false
      t.boolean :is_new, null: false, default: false
      t.float :random, limit: 53, null: false, default: 0
      t.string :touched, null: false, default: ''
      t.string :links_updated, null: false, default: ''
      t.integer :latest, null: false, default: 0
      t.integer :len, null: false, default: 0
      t.string :content_model
      t.string :lang

      t.timestamps
    end

    add_index :wikipedia_pages, [:namespace, :title], unique: true
    add_index :wikipedia_pages, :random
    add_index :wikipedia_pages, :len
    add_index :wikipedia_pages, [:is_redirect, :namespace, :len]
  end
end
