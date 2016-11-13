class CreateTweetVoices < ActiveRecord::Migration[5.0]
  def change
    create_table :tweet_voices do |t|
      t.integer  :tweet_seed_id, null: false
      t.string  :speacker_keyword, null: false
      t.string  :speech_file_path, null: false
      t.timestamps
    end
    add_index :tweet_voices, [:tweet_seed_id, :speacker_keyword]
  end
end
