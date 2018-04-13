class CreateDatapoolVideoMeta < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_video_meta do |t|
      t.string :type
      t.string :title, null: false
      t.text :front_image_url
      t.integer :data_category, null: false, default: 0
      t.integer :bitrate, null: false, default: 0
      t.string :origin_src, null: false
      t.text :other_src
      t.text :options
    end

    add_index :datapool_video_meta, :title
    add_index :datapool_video_meta, :origin_src
  end
end
