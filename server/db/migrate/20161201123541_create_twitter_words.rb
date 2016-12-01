class CreateTwitterWords < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_words do |t|
      t.integer :tweet_appear_word_id, null: false
      t.string :twitter_user_id, null: false
      t.string :twitter_user_name
      t.string :twitter_tweet_id, null: false
      t.datetime :tweet_created_at, null: false
      t.timestamps
    end
    add_index :twitter_words, :tweet_appear_word_id
    add_index :twitter_words, :tweet_created_at
    add_index :twitter_words, :twitter_user_id
  end
end
