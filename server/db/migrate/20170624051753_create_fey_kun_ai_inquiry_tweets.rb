class CreateFeyKunAiInquiryTweets < ActiveRecord::Migration[5.1]
  def change
    create_table :fey_kun_ai_inquiry_tweets do |t|
      t.string :twitter_user_id, null: false
      t.string :twitter_user_name, null: false
      t.string :tweet_id, null: false
      t.string :tweet, null: false
      t.string :token, null: false
      t.string :return_tweet
      t.string :place_name
      t.float :lat
      t.float :lon
      t.integer :tweet_quoted_id
      t.datetime :tweet_created_at, null: false
    end
    add_index :fey_kun_ai_inquiry_tweets, :tweet_id, unique: true, name: "fka_inquiry_tweet_id_index"
    add_index :fey_kun_ai_inquiry_tweets, :token, unique: true, name: "fka_inquiry_token_index"
    add_index :fey_kun_ai_inquiry_tweets, :twitter_user_id, name: "fka_inquiry_user_id_index"
    add_index :fey_kun_ai_inquiry_tweets, :twitter_user_name, name: "fka_inquiry_user_name_index"
    add_index :fey_kun_ai_inquiry_tweets, [:lat, :lon], name: "fka_inquiry_lat_lon_index"
    add_index :fey_kun_ai_inquiry_tweets, :tweet_quoted_id, name: "fka_inquiry_quoted_id_index"
  end
end
