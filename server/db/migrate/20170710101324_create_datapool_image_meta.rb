class CreateDatapoolImageMeta < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_image_meta do |t|
      t.string :type
      t.string :title, null: false
      t.string :original_filename
      t.string :src
      t.string :from_url
    end
    add_index :datapool_image_meta, :title
    add_index :datapool_image_meta, [:from_url, :src], unique: true
  end
end
