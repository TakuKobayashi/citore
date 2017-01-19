class CreateEmotionalWords < ActiveRecord::Migration[5.0]
  def change
    create_table :emotional_words do |t|
      t.string :word, null: false
      t.integer :language, null: false, default: 0
      t.string :reading, null: false
      t.string :part, null: false
      t.float :score, null: false
    end
    add_index :emotional_words, [:word, :part, :reading], unique: true
  end
end
