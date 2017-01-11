class CreateWordToMarkovs < ActiveRecord::Migration[5.0]
  def change
    create_table :word_to_markovs do |t|
      t.string :source_type, null: false
      t.integer :source_id, null: false
      t.integer :markov_trigram_id, null: false
    end
    add_index :word_to_markovs, [:markov_trigram_id, :source_type,:source_id], name: "word_to_markovs_index"
    add_index :word_to_markovs, [:source_type,:source_id], name: "word_to_markovs_source_index"
  end
end
