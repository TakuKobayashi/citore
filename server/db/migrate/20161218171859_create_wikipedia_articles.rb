class CreateWikipediaArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :wikipedia_articles do |t|
      t.integer :wikipedia_page_id, null: false, default: 0
      t.string :title, null: false, default: ''
      t.text :body, limit: 4294967295
      t.timestamps
    end
    add_index :wikipedia_articles, :wikipedia_page_id
    add_index :wikipedia_articles, :title
  end
end
