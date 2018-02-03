class CreateHackathonMusichackday2018RemixSounds < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_musichackday2018_remix_sounds do |t|
      t.integer :user_id, null: false
      t.integer :state, null: false, default: 0
      t.integer :to_user_id, null: false
      t.integer :base_sound_id, null: false
      t.integer :over_sound_id, null: false
      t.string :remix_file_url
      t.text :options
      t.timestamps
    end
    add_index :hackathon_musichackday2018_remix_sounds, :user_id
    add_index :hackathon_musichackday2018_remix_sounds, :to_user_id
  end
end
