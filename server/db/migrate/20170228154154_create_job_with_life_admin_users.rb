class CreateJobWithLifeAdminUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :job_with_life_admin_users do |t|
      t.integer :daily_reset_hour, null: false, default: 0
      t.string :name, null: false
      t.string :password, null: false
      t.timestamps
    end
    add_index :job_with_life_admin_users, [:name, :password], name: "record_job_admin_user_login_index"
  end
end
