class CreateJobWithLifeBeaconAccessLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :job_with_life_beacon_access_logs do |t|
      t.string :answer_user_type, null: false
      t.integer :answer_user_id, null: false
      t.datetime :record_time, null: false
      t.integer :daily_record_number, null: false, default: 0
      t.string :hwid, null: false
      t.timestamps
    end
    add_index :job_with_life_beacon_access_logs, [:answer_user_type, :answer_user_id], name: "record_job_user_index"
    add_index :job_with_life_beacon_access_logs, :record_time, name: "record_job_time_index"
    add_index :job_with_life_beacon_access_logs, :hwid, name: "record_job_hwid_index"
  end
end
