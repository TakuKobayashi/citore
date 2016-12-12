class CreateWikipediaTopicCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :wikipedia_topic_categories do |t|
      t.string :title, null: false, default: ''
      t.integer :pages, null: false, default: 0
      t.integer :subcats, null: false, default: 0
      t.integer :files, null: false, default: 0
    end
    add_index :wikipedia_topic_categories, :title, unique: true
    add_index :wikipedia_topic_categories, :pages
  end
end
