class CreateHackathonMusichackday2018SoundPlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :hackathon_musichackday2018_sound_players do |t|
      t.integer :user_id, null: false
      t.integer :state, null: false, default: 0
      t.integer :log_id, null: false
      t.datetime :sound_played_at
      t.float :sound_duration, null: false, default: 0
    end
    add_index :hackathon_musichackday2018_sound_players, :user_id
    add_index :hackathon_musichackday2018_sound_players, :log_id
    add_index :hackathon_musichackday2018_sound_players, :sound_played_at, name: "musichackday2018_sound_players_sound_played_at_index"
  end
end
