class CreateHomepageArticles < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_articles do |t|
      t.string :title, null: false
      t.text :description
      t.string :url, null: false
      t.string :thumbnail_url
      t.datetime :pubulish_at, null: false
      t.timestamps
    end
    add_index :homepage_articles, :pubulish_at
  end
end
