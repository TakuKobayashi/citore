class CreateDatapoolThreedModelCompoments < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_threed_model_compoments do |t|
      t.integer :threed_model_id, null: false
      t.string :title, null: false
      t.string :original_filepath
      t.boolean :important, null: false, default: false
      t.integer :data_category, null: false, default: 0
      t.string :origin_src, null: false
      t.text :query
      t.text :options
    end

    add_index :datapool_threed_model_compoments, :threed_model_id
    add_index :datapool_threed_model_compoments, :title
    add_index :datapool_threed_model_compoments, :origin_src
  end
end
