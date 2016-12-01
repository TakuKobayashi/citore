class CreateTweetAppearWords < ActiveRecord::Migration[5.0]
  def change
    create_table :tweet_appear_words do |t|
      t.integer :appear_count, null: false, default: 0
      t.string  :word, null: false
      t.string  :part, null: false
      t.timestamps
    end
    add_index :tweet_appear_words, [:word, :part], unique: true
  end
end
