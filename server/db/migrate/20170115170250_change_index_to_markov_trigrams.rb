class ChangeIndexToMarkovTrigrams < ActiveRecord::Migration[5.0]
  def change
    remove_index :markov_trigrams, [:first_gram, :second_gram, :third_gram]
    add_index :markov_trigrams, :first_gram
  end
end
