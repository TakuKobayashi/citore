class CreateCrawlTargetUrls < ActiveRecord::Migration[5.0]
  def change
    create_table :crawl_target_urls do |t|
      t.string :source_type, null: false
      t.string :protocol, null: false
      t.string :method, null: false
      t.string :host, null: false
      t.string :path, null: false
      t.text :params, null: false
      t.datetime :crawled_at
      t.timestamps
    end

    add_index :crawl_target_urls, :source_type
    add_index :crawl_target_urls, [:host, :path]
    add_index :crawl_target_urls, :crawled_at
  end
end
