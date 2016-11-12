class CreateTweetSeeds < ActiveRecord::Migration[5.0]
  def change
    create_table :tweet_seeds do |t|
      t.string  :tweet_id_str, null: false
      t.string  :tweet, null: false
      t.string  :search_keyword, null: false
      t.string  :speech_file_path
      t.timestamps
    end
    add_index :tweet_seeds, :tweet_id_str, unique: true
    add_index :tweet_seeds, :search_keyword
  end
end
