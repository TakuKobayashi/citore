class AddColumnToTwitterWords < ActiveRecord::Migration[5.0]
  def change
    add_column :twitter_words, :reply_to_tweet_id, :string
    add_index :twitter_words, :reply_to_tweet_id
  end
end
