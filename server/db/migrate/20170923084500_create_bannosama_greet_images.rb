class CreateBannosamaGreetImages < ActiveRecord::Migration[5.1]
  def change
    create_table :bannosama_greet_images do |t|
      t.integer :greet_id, null: false
      t.string :origin_file_name, null: false
      t.string :upload_url, null: false
      t.float :score, null: false, default: 0
      t.integer :width, null: false, default: 0
      t.integer :height, null: false, default: 0
      t.text :options
    end

    add_index :bannosama_greet_images, :greet_id
    add_index :bannosama_greet_images, :score
  end
end
