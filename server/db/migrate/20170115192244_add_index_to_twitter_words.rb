class AddIndexToTwitterWords < ActiveRecord::Migration[5.0]
  def change
    remove_index :twitter_words, :twitter_tweet_id
    add_index :twitter_words, :twitter_tweet_id, unique: true
  end
end
