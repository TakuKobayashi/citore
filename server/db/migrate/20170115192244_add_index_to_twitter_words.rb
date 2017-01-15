class AddIndexToTwitterWords < ActiveRecord::Migration[5.0]
  def change
    add_index :twitter_words, :twitter_tweet_id
  end
end
