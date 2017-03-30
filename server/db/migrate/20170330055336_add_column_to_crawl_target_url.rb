class AddColumnToCrawlTargetUrl < ActiveRecord::Migration[5.0]
  def change
  	add_column :crawl_target_urls, :request_method_category, :integer, null: false, default: 0
    add_column :crawl_target_urls, :target_class_column_extension_json, :text
  end
end
