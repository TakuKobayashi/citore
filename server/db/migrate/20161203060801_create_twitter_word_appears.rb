class CreateTwitterWordAppears < ActiveRecord::Migration[5.0]
  def change
    create_table :twitter_word_appears do |t|
      t.integer :tweet_appear_word_id, null: false
      t.integer :twitter_word_id, null: false
      t.timestamps
    end
    add_index :twitter_word_appears, [:tweet_appear_word_id, :twitter_word_id], name: "twitter_word_appears_relation_index"
  end
end
