class CreateCrawlSchedulers < ActiveRecord::Migration[5.0]
  def change
    create_table :crawl_schedulers do |t|
      t.integer :state, null: false, default: 0
      t.integer :search_kind, null: false, default: 0
      t.string  :search_word, null: false
      t.string  :resource_type
      t.integer :resource_id
      t.datetime :start_time
      t.datetime :completed_time
      t.timestamps
    end
  end
end
