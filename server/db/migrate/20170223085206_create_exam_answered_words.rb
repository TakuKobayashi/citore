class CreateExamAnsweredWords < ActiveRecord::Migration[5.0]
  def change
    create_table :exam_answered_words do |t|
      t.string :answer_user_type, null: false
      t.integer :answer_user_id, null: false
      t.integer :answer_category, null: false, default: 0
      t.integer :exam_question_id, null: false
      t.integer :exam_user_select_id, null: false
      t.text :answer_text
      t.integer :answer_choice_id
      t.boolean :judge, null: false, default: false
      t.float :score, null: false, default: 0
      t.timestamps
    end
    add_index :exam_answered_words, [:answer_user_type, :answer_user_id], name: "exam_answer_user_index"
    add_index :exam_answered_words, :exam_question_id
    add_index :exam_answered_words, :answer_choice_id
    add_index :exam_answered_words, :exam_user_select_id
  end
end
