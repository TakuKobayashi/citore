class CreateCitoreAegigoeWords < ActiveRecord::Migration[5.0]
  def change
    create_table :citore_aegigoe_words do |t|
      t.integer :twitter_word_id
      t.string :origin, null: false
      t.string :reading, null: false
      t.integer :appear_count, null: false, default: 0
      t.timestamps
    end
    add_index :citore_aegigoe_words, :twitter_word_id
  end
end
