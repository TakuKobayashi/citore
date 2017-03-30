class AddColumnToCrawlTargetUrl < ActiveRecord::Migration[5.0]
  def change
    add_column :crawl_target_urls, :title, :string, null: false, default: ""
    add_column :crawl_target_urls, :append_to_url_page_variable, :string
    add_column :crawl_target_urls, :start_page_num, :integer, null: false, default: 0
    add_column :crawl_target_urls, :end_page_num, :integer, null: false, default: 0
    add_column :crawl_target_urls, :request_method_category, :integer, null: false, default: 0
    add_column :crawl_target_urls, :target_class_column_extension_json, :text
  end
end
