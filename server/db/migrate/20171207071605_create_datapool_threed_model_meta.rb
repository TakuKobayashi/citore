class CreateDatapoolThreedModelMeta < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_threed_model_meta do |t|
      t.string :type
      t.string :title, null: false
      t.string :origin_src, null: false
      t.text :other_src
      t.text :options
    end

    add_index :datapool_threed_model_meta, :title
    add_index :datapool_threed_model_meta, :origin_src
  end
end
