class CreateMarkovTrigramWords < ActiveRecord::Migration[5.0]
  def change
    create_table :markov_trigram_words do |t|
      t.integer :markov_trigram_prefix_id, null: false
      t.string :second_word, null: false, default: ""
      t.string :third_word, null: false, default: ""
      t.integer :appear_count, null: false, default: 0
    end
    add_index :markov_trigram_words, [:markov_trigram_prefix_id, :second_word, :third_word], unique: true, name: "markov_trigram_words_indexes"
  end
end
