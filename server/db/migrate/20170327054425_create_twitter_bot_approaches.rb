class CreateTwitterBotApproaches < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_bot_approaches do |t|
      t.string :twitter_user_id, null: false
      t.string :twitter_user_name, null: false
      t.integer :action, null: false
      t.string :twitter_tweet_id
      t.string :tweet
    end

    add_index :twitter_bot_approaches, :twitter_user_id
    add_index :twitter_bot_approaches, :twitter_tweet_id
  end
end
