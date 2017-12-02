class CreateHackathonSunflowerCompositeWorkers < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_sunflower_composite_workers do |t|
      t.integer :user_id
      t.string :export_url
      t.integer :category, null: false, dfault: 0
      t.integer :state, null: false, dfault: 0
      t.text :options
      t.timestamps
    end
    add_index :hackathon_sunflower_composite_workers, :user_id, name: "composite_worker_user_id_index"
    add_index :hackathon_sunflower_composite_workers, [:state, :category], name: "composite_worker_state_category_index"
  end
end
