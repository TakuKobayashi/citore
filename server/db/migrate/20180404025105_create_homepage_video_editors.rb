class CreateHomepageVideoEditors < ActiveRecord::Migration[5.1]
  def change
    create_table :homepage_video_editors do |t|
      t.integer :homepage_access_id, null: false
      t.integer :state, null: false, default: 0
      t.string :upload_video_url
      t.string :edited_video_url
      t.text :execute_command
      t.text :options
      t.timestamps
    end

    add_index :homepage_video_editors, :homepage_access_id
  end
end
