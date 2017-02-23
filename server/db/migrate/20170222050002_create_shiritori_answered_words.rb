class CreateShiritoriAnsweredWords < ActiveRecord::Migration[5.0]
  def change
    create_table :shiritori_answered_words do |t|
      t.string :answer_user_type, null: false
      t.integer :answer_user_id, null: false
      t.string :input_word, null: false
      t.string :output_word, null: false
      t.integer :answered_word_id, null: false
      t.integer :shiritori_round_id, null: false
      t.string :next_prefix, null: false, default: ""
      t.timestamps
    end
    add_index :shiritori_answered_words, [:answer_user_type,:answer_user_id], name: "shiritori_answer_user_index"
    add_index :shiritori_answered_words, [:input_word, :shiritori_round_id], unique: true, name: "shiritori_answer_input_round_index"
    add_index :shiritori_answered_words, [:output_word, :shiritori_round_id], unique: true, name: "shiritori_answer_output_round_index"
  end
end
