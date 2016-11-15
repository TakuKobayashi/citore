class CreateEmotionalWordDictionaries < ActiveRecord::Migration[5.0]
  def change
    create_table :emotional_word_dictionaries do |t|
      t.string  :part, null: false
      t.string  :word, null: false
      t.string  :reading, null: false
      t.float   :score, null: false, default: 0
      t.timestamps
    end
    add_index :emotional_word_dictionaries, :word
    add_index :emotional_word_dictionaries, :reading
  end
end
