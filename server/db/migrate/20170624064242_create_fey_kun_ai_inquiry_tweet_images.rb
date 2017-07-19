class CreateFeyKunAiInquiryTweetImages < ActiveRecord::Migration[5.1]
  def change
    create_table :fey_kun_ai_inquiry_tweet_images do |t|
      t.integer :inquiry_tweet_id, null: false
      t.string :image_url, null: false
      t.text :exifs
      t.string :checksum, null: false
      t.text :output
    end
    add_index :fey_kun_ai_inquiry_tweet_images, [:inquiry_tweet_id, :image_url], name: "fka_inquiry_image_id_url_index"
  end
end
