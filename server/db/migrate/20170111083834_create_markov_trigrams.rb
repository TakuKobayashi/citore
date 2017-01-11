class CreateMarkovTrigrams < ActiveRecord::Migration[5.0]
  def change
    create_table :markov_trigrams do |t|
      t.string :source_type, null: false
      t.integer :source_id, null: false
      t.string :first_gram, null: false, default: ""
      t.string :second_gram, null: false, default: ""
      t.string :third_gram, null: false, default: ""
      t.boolean :is_end, null: false, default: false
    end
    add_index :markov_trigrams, [:source_type, :source_id]
    add_index :markov_trigrams, [:first_gram, :second_gram, :third_gram], name: "markov_trigram_word_index"
  end
end
