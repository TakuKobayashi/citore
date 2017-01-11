class CreateTwitterWordMentions < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_word_mentions do |t|
      t.string :twitter_user_id, null: false
      t.string :twitter_user_name
      t.string :twitter_tweet_id, null: false
      t.string :tweet, null: false
      t.text :csv_url
      t.string :reply_to_tweet_id
      t.datetime :tweet_created_at, null: false
    end
    add_index :twitter_word_mentions, :tweet_created_at
    add_index :twitter_word_mentions, :twitter_user_id
    add_index :twitter_word_mentions, :twitter_tweet_id
    add_index :twitter_word_mentions, :reply_to_tweet_id
  end
end
