class CreateYoutubeChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :youtube_channels do |t|
      t.integer :youtube_category_id
      t.string :channel_id, null: false, default: ''
      t.string :title, null: false, default: ''
      t.text :description
      t.integer :comment_count, null: false, default: 0
      t.integer :subscriber_count, null: false, default: 0
      t.integer :video_count, null: false, default: 0
      t.integer :view_count, null: false, default: 0, limit: 8
      t.string :thumnail_image_url, null: false, default: ''
      t.datetime :published_at
    end

    add_index :youtube_channels, :youtube_category_id
    add_index :youtube_channels, :published_at
    add_index :youtube_channels, :channel_id, unique: true
  end
end
