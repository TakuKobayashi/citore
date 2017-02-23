class CreateExamQuestionChoices < ActiveRecord::Migration[5.0]
  def change
    create_table :exam_question_choices do |t|
      t.integer :exam_question_id, null: false
      t.string :number_word, null: false, default: ""
      t.integer :number, null: false, default: 1
      t.text :body, null: false
    end
    add_index :exam_question_choices, :exam_question_id
  end
end
