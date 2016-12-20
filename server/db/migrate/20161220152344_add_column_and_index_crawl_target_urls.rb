class AddColumnAndIndexCrawlTargetUrls < ActiveRecord::Migration[5.0]
  def change
    add_column :crawl_target_urls, :source_id, :integer
    add_index :crawl_target_urls, [:source_type, :source_id]
  end
end
