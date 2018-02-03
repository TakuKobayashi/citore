class CreateHackathonMusichackday2018PlaySoundLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_musichackday2018_play_sound_logs do |t|
      t.integer :user_id, null: false
      t.integer :state, null: false, default: 0
      t.string :sound_type, null: false
      t.integer :sound_id, null: false
      t.integer :next_sound_id
      t.timestamps
    end
    add_index :hackathon_musichackday2018_play_sound_logs, :user_id
    add_index :hackathon_musichackday2018_play_sound_logs, [:sound_type, :sound_id], name: "musichackday2018_sound_resource_log_index"
  end
end
