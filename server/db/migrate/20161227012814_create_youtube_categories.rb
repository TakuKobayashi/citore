class CreateYoutubeCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_categories do |t|
      t.string :category_id, null: false, default: ''
      t.integer :kind, null: false, limit: 1
      t.string :channel_id, null: false, default: ''
      t.string :title, null: false, default: ''
      t.timestamps
    end

    add_index :youtube_categories, :title
  end
end
