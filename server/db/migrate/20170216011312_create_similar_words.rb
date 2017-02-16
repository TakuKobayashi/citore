class CreateSimilarWords < ActiveRecord::Migration[5.0]
  def change
    create_table :similar_words do |t|
      t.integer :from_word_id, null: false
      t.integer :to_word_id, null: false
      t.float :score, null: false, default: 0
      t.string :from_key, null: false, default: ""
    end
    add_index :similar_words, [:from_word_id, :to_word_id, :from_key], unique: true, name: "similar_words_indexes"
  end
end
