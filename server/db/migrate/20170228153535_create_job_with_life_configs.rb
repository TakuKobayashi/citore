class CreateJobWithLifeConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :job_with_life_configs do |t|
      t.integer :job_with_life_admin_user_id, null: false
      t.string :hwid, null: false
      t.timestamps
    end
    add_index :job_with_life_configs, :job_with_life_admin_user_id, name: "record_job_config_admin_user_index"
    add_index :job_with_life_configs, :job_with_life_admin_user_id, name: "record_job_config_hwid_index"
  end
end
