class CreateNgramWords < ActiveRecord::Migration[5.0]
  def change
    create_table :ngram_words do |t|
      t.string :from_type, null: false
      t.integer :from_id, null: false
      t.string :bigram, null: false
      t.timestamps
    end
    add_index :ngram_words, [:from_type, :from_id, :bigram], unique: true, name: "ngeam_from_indexes"
    add_index :ngram_words, :bigram
  end
end
