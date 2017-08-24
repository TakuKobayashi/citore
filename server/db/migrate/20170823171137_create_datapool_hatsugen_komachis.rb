class CreateDatapoolHatsugenKomachis < ActiveRecord::Migration[5.1]
  def change
    create_table :datapool_hatsugen_komachis do |t|
      t.integer :topic_id, null: false
      t.string :res_number, null: false
      t.string :top_res_flag, null: false
      t.string :title, null: false
      t.text :body
      t.string :handle_name, null: false
      t.datetime :posted_at, null: false
      t.string :publish_flag, null: false
      t.string :parent_topic_flag, null: false
      t.integer :komachi_user_id, limit: 8, null: false
      t.text :advice
      t.integer :funny, null: false, default: 0
      t.integer :surprise, null: false, default: 0
      t.integer :tears, null: false, default: 0
      t.integer :yell, null: false, default: 0
      t.integer :isee, null: false, default: 0
      t.string :genre_code, null: false, default: ""
      t.string :res_state
      t.string :facemark_id
      t.text :remark
      t.string :post_device
    end

    add_index :datapool_hatsugen_komachis, [:topic_id, :res_number]
    add_index :datapool_hatsugen_komachis, :komachi_user_id
    add_index :datapool_hatsugen_komachis, :genre_code
    add_index :datapool_hatsugen_komachis, :posted_at
  end
end
