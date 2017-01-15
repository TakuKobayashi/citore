class ChangeIndexToMarkovTrigrams < ActiveRecord::Migration[5.0]
  def change
    remove_index :markov_trigrams, "markov_trigram_word_index"
    add_index :markov_trigrams, :first_gram
  end
end
