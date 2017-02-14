class CreateMarkovTrigramPrefixes < ActiveRecord::Migration[5.0]
  def change
    create_table :markov_trigram_prefixes do |t|
      t.string :source_type, null: false
      t.string :prefix, null: false, default: ""
      t.integer :state, null: false, default: 0
      t.integer :unique_count, null: false, default: 0
      t.integer :sum_count, null: false, default: 0
    end
    add_index :markov_trigram_prefixes, [:prefix, :state, :source_type], unique: true, name: "markov_trigram_prefixes_indexes"
  end
end
