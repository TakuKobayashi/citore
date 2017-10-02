class CreateHomepageUploadJobQueues < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_upload_job_queues do |t|
      t.integer :homepage_access_id, null: false
      t.string :from_type, null: false
      t.string :token, null: false
      t.integer :state, null: false, default: 0
      t.string :upload_url
      t.integer :upload_file_size
      t.text :options
      t.timestamps
    end

    add_index :homepage_upload_job_queues, [:homepage_access_id, :state], name: "homepage_job_queue_user_index"
    add_index :homepage_upload_job_queues, :token, name: "homepage_job_queue_token_index"
    add_index :homepage_upload_job_queues, :created_at, name: "homepage_job_queue_created_at_index"
  end
end
