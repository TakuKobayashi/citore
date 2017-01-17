class CreateMarkovTrigrams < ActiveRecord::Migration[5.0]
  def change
    create_table :markov_trigrams do |t|
      t.string :source_type, null: false
      t.string :prefix, null: false, default: ""
      t.text :others_json, null: false
      t.integer :state, null: false, default: 0
    end
    add_index :markov_trigrams, [:prefix, :state], unique: true
  end
end
