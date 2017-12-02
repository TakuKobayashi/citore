class CreateHackathonSunflowerImageResources < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_sunflower_image_resources do |t|
      t.integer :user_id
      t.string :url, null: false
      t.integer :category, null: false, default: 0
      t.integer :state, null: false, dfault: 0
      t.integer :width, null: false, default: 0
      t.integer :height, null: false, default: 0
      t.text :options
      t.timestamps
    end
    add_index :hackathon_sunflower_image_resources, :user_id
  end
end
