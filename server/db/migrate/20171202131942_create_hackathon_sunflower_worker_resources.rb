class CreateHackathonSunflowerWorkerResources < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_sunflower_worker_resources do |t|
      t.integer :user_id
      t.integer :worker_id, null: false
      t.integer :resource_id, null: false
      t.integer :adjust_width, null: false, default: 0
      t.integer :adjust_height, null: false, default: 0
      t.integer :column_index, null: false, default: 0
      t.integer :row_index, null: false, default: 0
    end
    add_index :hackathon_sunflower_worker_resources, :user_id, name: "composite_worker_resources_user_id_index"
    add_index :hackathon_sunflower_worker_resources, [:worker_id, :resource_id], name: "composite_worker_resources_worker_resource_index"
  end
end
